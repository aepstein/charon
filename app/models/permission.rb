class Permission < ActiveRecord::Base
  belongs_to :framework
  belongs_to :role
  has_many :bases, :primary_key => :framework_id, :foreign_key => :framework_id
  has_many :requests, :through => :bases, :conditions => "permissions.status = requests.status"
  has_many :requirements, :dependent => :delete_all
  has_many :memberships, :primary_key => :role_id, :foreign_key => :role_id, :conditions => { :active => true }
  has_many :users, :through => :memberships

  validates_presence_of :role
  validates_presence_of :framework
  validates_inclusion_of :action, :in => Request::ACTIONS
  validates_inclusion_of :perspective, :in => Edition::PERSPECTIVES
  validates_inclusion_of :status, :in => Request.aasm_state_names

  named_scope :with_requirements, :joins => 'LEFT JOIN requirements ON permissions.id = requirements.permission_id'
  # Needs requirements and memberships tables
  named_scope :with_fulfillments, :joins => 'LEFT JOIN fulfillments ON ' +
    'requirements.fulfillable_type = fulfillments.fulfillable_type AND ' +
    'requirements.fulfillable_id = fulfillments.fulfillable_id AND ' +
    "( (fulfillments.fulfiller_type = 'Organization' AND fulfillments.fulfiller_id = memberships.organization_id) OR " +
    "(fulfillments.fulfiller_type = 'User' AND fulfillments.fulfiller_id = memberships.user_id) )"
  # Needs requirements and fulfillments tables
  named_scope :fulfilled, :group => 'permissions.id',
    :having => 'COUNT(fulfillments.id) = COUNT(requirements.id)'
  # Needs requirements and fulfillments tables
  named_scope :unfulfilled, :group => 'permissions.id',
    :having => 'COUNT(fulfillments.id) < COUNT(requirements.id)'
  # Needs memberships table
  named_scope :perspectives_in, lambda { |perspectives|
    { :conditions => perspectives.map { |perspective|
        "permissions.perspective = #{connection.quote perspective.shift} AND memberships.organization_id IN (#{perspective.join ','})"
      }.join( ' OR ' )
    }
  }
  # Must have memberships table related
  scope_procedure :satisfied, lambda {
    fulfilled.with_fulfillments.with_requirements
  }
  # Must have memberships table related
  scope_procedure :unsatisfied, lambda {
    unfulfilled.with_fulfillments.with_requirements
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

