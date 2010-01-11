class Requirement < ActiveRecord::Base
  belongs_to :permission
  belongs_to :fulfillable, :polymorphic => true

  validates_presence_of :permission
  validates_presence_of :fulfillable
  validates_uniqueness_of :permission_id, :scope => [ :fulfillable_id, :fulfillable_type ]
  validates_inclusion_of :fulfillable_type, :in => Fulfillment::FULFILLABLE_TYPES.values.flatten


  # Must have memberships table related
  named_scope :with_fulfillments, :joins => 'LEFT JOIN fulfillments ON ' +
    'requirements.fulfillable_type = fulfillments.fulfillable_type AND ' +
    'requirements.fulfillable_id = fulfillments.fulfillable_id AND ' +
    "( (fulfillments.fulfiller_type = 'Organization' AND fulfillments.fulfiller_id = memberships.organization_id) OR " +
    "(fulfillments.fulfiller_type = 'User' AND fulfillments.fulfiller_id = memberships.user_id) )"
  named_scope :fulfilled, :conditions => 'fulfillments.id IS NOT NULL'
  named_scope :unfulfilled, :conditions => 'fulfillments.id IS NULL'

  # When action = 'create' AND status = 'started', don't look at memberships
  # When perspective = 'requestor' membership must exist for an organization with request from basis in framework
  # When perspective = 'reviewer' membership must exist for an organization with basis in framework
end

