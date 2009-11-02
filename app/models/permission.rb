class Permission < ActiveRecord::Base
  has_and_belongs_to_many :agreements
  belongs_to :framework
  belongs_to :role

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

  delegate :may_update?, :to => :framework
  delegate :may_see?, :to => :framework

  def may_create?(user)
    may_update? user
  end

  def may_destroy?(user)
    may_update? user
  end
end

