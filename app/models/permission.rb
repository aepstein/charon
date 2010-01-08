class Permission < ActiveRecord::Base
  has_and_belongs_to_many :agreements
  belongs_to :framework
  belongs_to :role
  has_many :bases, :through => :framework
  has_many :requests, :through => :bases
  has_many :memberships, :through => :role, :conditions => { :active => true }

  validates_presence_of :role
  validates_presence_of :framework
  validates_inclusion_of :action, :in => Request::ACTIONS
  validates_inclusion_of :perspective, :in => Edition::PERSPECTIVES
  validates_inclusion_of :status, :in => Request.aasm_state_names

  named_scope :role, lambda { |role_ids|
    { :conditions => { :role_id => role_ids } }
  }
  named_scope :action, lambda { |actions|
    { :conditions => { :action => actions } }
  }
  named_scope :perspective, lambda { |perspectives|
    { :conditions => { :perspective => perspectives } }
  }
  named_scope :status, lambda { |statuses|
    { :conditions => { :status => statuses } }
  }
  named_scope :user_agrees, lambda { |user|
    subquery = "SELECT approvable_id FROM approvals WHERE user_id = ? AND " +
      "approvable_type = 'Agreement'"
    { :conditions => ['0 = (SELECT COUNT(*) FROM agreements_permissions WHERE ' +
        "permission_id = permissions.id AND agreement_id NOT IN (#{subquery}) )",
        user.id ] }
  }
  named_scope :with_fulfillments, lambda {
    { :joins => [ :memberships, 'LEFT JOIN requirements ON requirements.permission_id = permissions.id ' +
        'LEFT JOIN fulfillments ON requirements.fulfillable_type = fulfillments.fulfillable_type ' +
        'AND requirements.fulfillable_id = fulfillments.fulfillable_id AND' +
        "( (fulfillments.fulfiller_type = 'User' AND fulfiller_id = memberships.user_id) OR " +
        "(fulfillments.fulfiller_type = 'Organization' AND fulfiller_id = memberships.organization_id) )" ],
      :group => 'permissions.id'
    }
  }
  named_scope :with_request_id, lambda { |request_id|
    { :joins => "INNER JOIN bases INNER JOIN requests INNER JOIN organizations_requests INNER JOIN memberships",
      :conditions => [
        "permissions.framework_id = bases.framework_id AND bases.id = requests.basis_id AND " +
        "requests.id = organizations_requests.request_id AND requests.id = ? AND " +
        "permissions.status = requests.status AND " +
        "( ( memberships.organization_id = organizations_requests.organization_id AND " +
        " permissions.perspective = 'requestor' ) OR " +
        "( memberships.organization_id = bases.organization_id AND permissions.perspective = 'reviewer' ) ) AND " +
        "memberships.active = #{connection.quote true} AND memberships.role_id = permissions.role_id",
        request_id
      ]
    }
  }
  named_scope :with_user_id, lambda { |user_id|
    { :joins => [ :memberships ], :conditions => [ 'memberships.user_id = ?', user_id ] }
  }
  named_scope :fulfilled, :having => 'COUNT(fulfillments.id) = COUNT(requirements.id)'
  named_scope :unfulfilled, :having => 'COUNT(fulfillments.id) < COUNT(requirements.id)'
  scope_procedure :fulfilled_for, lambda { |user_id, request_id|
    with_fulfillments.with_user_id(user_id).with_request_id(request_id).fulfilled
  }
  scope_procedure :unfulfilled_for, lambda { |user_id, request_id|
    with_fulfillments.with_user_id(user_id).with_request_id(request_id).unfulfilled
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

