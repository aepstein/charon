class Permission < ActiveRecord::Base
  PERSPECTIVES = %w( requestors reviewer )
  belongs_to :framework
  belongs_to :role

  validates_presence_of :role
  validates_presence_of :framework
  validates_inclusion_of :action, :in => Request::ACTIONS
  validates_inclusion_of :perspective, :in => PERSPECTIVES
  validates_inclusion_of :status, :in => Request.aasm_states

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
end

