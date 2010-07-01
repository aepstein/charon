class Framework < ActiveRecord::Base
  default_scope :order => 'frameworks.name ASC'

  has_many :approvers
  has_many :requirements

  named_scope :with_fulfillments_for, lambda { |fulfiller, perspective, role_ids|
    { :joins => 'LEFT JOIN requirements ON requirements.framework_id = frameworks.id ' +
        "AND requirements.perspectives_mask & #{2**Edition::PERSPECTIVES.index(perspective)} > 0 " +
        "AND requirements.fulfillable_type IN (#{Fulfillment.quoted_types_for(fulfiller)}) AND " +
        ( (role_ids && !role_ids.empty?) ? "(requirements.role_id IS NULL OR " +
          "requirements.role_id IN (#{role_ids.join ','}) ) " : "requirements.role_id IS NULL " ) +
        'LEFT JOIN fulfillments ON requirements.fulfillable_id = fulfillments.fulfillable_id AND ' +
        'requirements.fulfillable_type = fulfillments.fulfillable_type AND ' +
        "fulfillments.fulfiller_id = #{fulfiller.id}",
      :group => 'frameworks.id' }
  }
  named_scope :fulfilled, :having => 'COUNT(requirements.id) <= COUNT(fulfillments.id)'
  named_scope :unfulfilled, :having => 'COUNT(requirements.id) > COUNT(fulfillments.id)'
  scope_procedure :fulfilled_for, lambda { |fulfiller, perspective, role_ids|
    with_fulfillments_for(fulfiller, perspective, role_ids).fulfilled
  }
  scope_procedure :unfulfilled_for, lambda { |fulfiller, perspective, role_ids|
    with_fulfillments_for(fulfiller, perspective, role_ids).unfulfilled
  }

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_s; name; end
end

