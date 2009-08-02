class Permission < ActiveRecord::Base
  belongs_to :framework
  belongs_to :role

  validates_presence_of :role
  validates_presence_of :framework
  validates_inclusion_of :action, :in => Request::ACTIONS
  validates_inclusion_of :perspective, :in => Version::PERSPECTIVES
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

  delegate :may_update?, :to => :framework
  delegate :may_see?, :to => :framework

  def may_create?(user)
    may_update? user
  end

  def may_destroy?(user)
    may_update? user
  end
end

