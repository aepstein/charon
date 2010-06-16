class Requirement < ActiveRecord::Base
  belongs_to :framework
  belongs_to :fulfillable, :polymorphic => true
  belongs_to :role

  validates_presence_of :framework
  validates_presence_of :fulfillable
  validates_uniqueness_of :framework_id, :scope => [ :fulfillable_id, :fulfillable_type ]
  validates_inclusion_of :fulfillable_type, :in => Fulfillment::FULFILLABLE_TYPES.values.flatten

  named_scope :with_fulfillments_for, lambda { |fulfiller, perspective|
    { :joins => 'LEFT JOIN fulfillments ON requirements.fulfillable_id = fulfillments.fulfillable_id AND ' +
        'requirements.fulfillable_type = fulfillments.fulfillable_type AND ' +
        "fulfillments.fulfiller_id = #{fulfiller.id}",
      :group => 'requirements.id',
      :conditions => "requirements.perspectives_mask & #{2**Edition::PERSPECTIVES.index(perspective)} > 0 " +
      "AND requirements.fulfillable_type IN (#{Fulfillment.quoted_types_for(fulfiller)})" }
  }
  named_scope :fulfilled, :having => 'COUNT(requirements.id) <= COUNT(fulfillments.id)'
  named_scope :unfulfilled, :having => 'COUNT(requirements.id) > COUNT(fulfillments.id)'
  scope_procedure :fulfilled_for, lambda { |fulfiller, perspective|
    with_fulfillments_for(fulfiller, perspective).fulfilled
  }
  scope_procedure :unfulfilled_for, lambda { |fulfiller, perspective|
    with_fulfillments_for(fulfiller, perspective).unfulfilled
  }

  def perspectives=(perspectives)
    self.perspectives_mask = (perspectives & Edition::PERSPECTIVES).map { |p| 2**Edition::PERSPECTIVES.index(p) }.sum
  end

  def perspectives
    Edition::PERSPECTIVES.reject { |p| ((perspectives_mask || 0) & 2**Edition::PERSPECTIVES.index(p)).zero? }
  end

  def fulfiller_type; Fulfillment.fulfiller_type_for_fulfillable fulfillable_type; end

  def flat_fulfillable_id; "#{fulfillable_id}_#{fulfillable_type}"; end

  def to_s; fulfillable.to_s; end
end

