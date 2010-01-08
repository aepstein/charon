class Permission < ActiveRecord::Base
  belongs_to :framework
  belongs_to :role
  has_many :bases, :through => :framework
  has_many :requests, :through => :bases
  has_many :requirements, :dependent => :delete_all

  validates_presence_of :role
  validates_presence_of :framework
  validates_inclusion_of :action, :in => Request::ACTIONS
  validates_inclusion_of :perspective, :in => Edition::PERSPECTIVES
  validates_inclusion_of :status, :in => Request.aasm_state_names

  # Factored out of several scopes
  named_scope :with_bases, :joins => 'INNER JOIN bases', :conditions => 'permissions.framework_id = bases.framework_id'
  named_scope :with_memberships, :joins => 'INNER JOIN memberships',
    :conditions => "memberships.active = #{connection.quote true} AND memberships.role_id = permissions.role_id"
  # Requires with_memberships scope
  named_scope :with_fulfillments, lambda {
    { :joins => 'LEFT JOIN requirements ON requirements.permission_id = permissions.id ' +
        'LEFT JOIN fulfillments ON requirements.fulfillable_type = fulfillments.fulfillable_type ' +
        'AND requirements.fulfillable_id = fulfillments.fulfillable_id AND' +
        "( (fulfillments.fulfiller_type = 'User' AND fulfiller_id = memberships.user_id) OR " +
        "(fulfillments.fulfiller_type = 'Organization' AND fulfiller_id = memberships.organization_id) )",
      :group => 'permissions.id'
    }
  }
  # Requires with_memberships, with_bases scopes
  # Intended for a new request with basis and initial organization(s) specified
  named_scope :with_request_parameters, lambda { |basis_id, status, organization_ids|
    { :conditions =>  "bases.id = #{connection.quote basis_id} AND permissions.status = #{connection.quote status} AND (" +
        "( memberships.organization_id IN (#{organization_ids.join(',')}) AND permissions.perspective = 'requestor' ) OR " +
        "( memberships.organization_id = bases.organization_id AND permissions.perspective = 'reviewer' ) )"
    }
  }
  # Requires with_memberships, with_bases scopes
  named_scope :with_request_id, lambda { |request_id|
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
  named_scope :fulfilled, :having => 'COUNT(fulfillments.id) = COUNT(requirements.id)'
  # Requires with_fulfillments scope
  named_scope :unfulfilled, :having => 'COUNT(fulfillments.id) < COUNT(requirements.id)'
  scope_procedure :with_fulfillments_for, lambda { |u, r|
    with_fulfillments.with_memberships.with_bases.with_user_id(u.id).with_request_parameters(r.basis_id, r.status, r.organization_ids )
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

