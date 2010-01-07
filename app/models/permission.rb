class Permission < ActiveRecord::Base
  has_and_belongs_to_many :agreements
  belongs_to :framework
  belongs_to :role
  has_many :memberships, :through => :role

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
  named_scope :fulfilled, lambda {
    { :joins => 'LEFT JOIN requirements ON requirements.permission_id = permissions.id ' +
        'LEFT JOIN fulfillments ON requirements.fulfillable_type = fulfillments.fulfillable_type ' +
        'AND requirements.fulfillable_id = fulfillments.fulfillable_id',
      :having => 'COUNT(fulfillments.id) = COUNT(requirements.id)',
      :group => 'permissions.id',
      :conditions => [ "(fulfillments.fulfiller_type = 'User' AND fulfiller_id = memberships.user_id) OR " +
        "(fulfillments.fulfiller_type = 'Organization' AND fulfiller_id = memberships.organization_id)" ]
    }
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

