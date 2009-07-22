class Permission < ActiveRecord::Base
  CONTEXTS = %w( requestors reviewer )
  belongs_to :framework
  belongs_to :role

  validates_presence_of :role
  validates_presence_of :framework
  validates_inclusion_of :status, :in => Request.aasm_states
  validates_inclusion_of :action, :in => Request::ACTIONS
  validates_inclusion_of :context, :in => CONTEXTS

  named_scope :context, lambda { |contexts|
    { :conditions => { :context => contexts } }
  }
  named_scope :action, lambda { |actions|
    { :conditions => { :action => actions } }
  }
  named_scope :status, lambda { |statuses|
    { :conditions => { :status => statuses } }
  }
  named_scope :role, lambda { |roles|
    { :conditions => { :role => roles } }
  }
end

