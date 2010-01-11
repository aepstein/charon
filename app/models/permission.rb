class Permission < ActiveRecord::Base
  belongs_to :framework
  belongs_to :role
  has_many :bases, :primary_key => :framework_id, :foreign_key => :framework_id
  has_many :requests, :through => :bases, :conditions => "permissions.status = requests.status"
  has_many :requirements, :dependent => :delete_all
  has_many :memberships, :primary_key => :role_id, :foreign_key => :role_id

  validates_presence_of :role
  validates_presence_of :framework
  validates_inclusion_of :action, :in => Request::ACTIONS
  validates_inclusion_of :perspective, :in => Edition::PERSPECTIVES
  validates_inclusion_of :status, :in => Request.aasm_state_names

  # Factored out of several scopes
  # Requires memberships and bases
  # Intended for a new request with basis and initial organization(s) specified
  named_scope :with_request_parameters, lambda { |basis_id, statuses, organization_ids|
    statuses = [ statuses ] unless statuses.class == Array
    status_sql = statuses.map { |s| connection.quote s }.join ","
    { :conditions =>  "bases.id = #{connection.quote basis_id} AND permissions.status = #{status_sql} AND (" +
        "( memberships.organization_id IN (#{organization_ids.join(',')}) AND permissions.perspective = 'requestor' ) OR " +
        "( memberships.organization_id = bases.organization_id AND permissions.perspective = 'reviewer' ) )"
    }
  }
  scope_procedure :request_id_eq, lambda { |request_id| memberships_active_eq(true) }
  # Requires with_memberships, with_bases scopes
  named_scope :request_id_eq, lambda { |request_id|
    { :joins => "INNER JOIN requests INNER JOIN organizations_requests",
      :conditions => [
        "bases.id = requests.basis_id AND " +
        "requests.id = organizations_requests.request_id AND requests.id = ? AND " +
        "permissions.status = requests.status AND " +
        "( ( memberships.organization_id = organizations_requests.organization_id AND " +
        " permissions.perspective = 'requestor' ) OR " +
        "( memberships.organization_id = bases.organization_id AND permissions.perspective = 'reviewer' ) )",
        request_id
      ]
    }
  }
  # Requires with_memberships scope
  named_scope :with_user_id, lambda { |user_id|
    { :conditions => [ 'memberships.user_id = ?', user_id ] }
  }
  # Requires with_fulfillments scope
  named_scope :fulfilled, :having => 'COUNT(fulfillments.id) = COUNT(requirements.id)', :group => 'permissions.id'
  # Requires with_fulfillments scope
  named_scope :unfulfilled, :having => 'COUNT(fulfillments.id) < COUNT(requirements.id)', :group => 'permissions.id'
  scope_procedure :user_id_eq, lambda { |user_id| memberships_active_eq(true).memberships_user_id_eq(user_id) }
  scope_procedure :with_fulfillments_for, lambda { |u, r|
    requirements_with_fulfillments.user_id_eq(u.id).bases_open.with_request_parameters(r.basis_id, r.status, r.organization_ids )
  }
  scope_procedure :fulfilled_for, lambda { |u, r|
    with_fulfillments_for( u, r ).fulfilled
  }
  scope_procedure :unfulfilled_for, lambda { |u, r|
    with_fulfillments_for( u, r ).unfulfilled
  }

  delegate :may_update?, :to => :framework
  delegate :may_see?, :to => :framework

  def may_create?(user)
    may_update? user
  end

  def may_destroy?(user)
    may_update? user
  end
end

