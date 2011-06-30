class Framework < ActiveRecord::Base
  attr_accessible :name, :requirements_attributes

  has_many :approvers, :inverse_of => :framework
  has_many :requirements, :inverse_of => :framework
  has_many :bases, :inverse_of => :framework

  validates :name, :presence => true, :uniqueness => true

  accepts_nested_attributes_for :requirements,
    :reject_if => proc { |attributes| attributes['fulfillable_name'].blank? },
    :allow_destroy => true

  default_scope order( 'frameworks.name ASC' )

  scope :with_fulfillments_for, lambda { |fulfiller, perspective, role_ids|
    joins( 'LEFT JOIN requirements ON requirements.framework_id = frameworks.id ' +
      "AND requirements.perspectives_mask & #{2**Edition::PERSPECTIVES.index(perspective)} > 0 " +
      "AND requirements.fulfillable_type IN (#{fulfiller.class.quoted_fulfillable_types}) AND " +
      ( (role_ids && !role_ids.empty?) ? "(requirements.role_id IS NULL OR " +
      "requirements.role_id IN (#{role_ids.join ','}) ) " : "requirements.role_id IS NULL " ) +
      'LEFT JOIN fulfillments ON requirements.fulfillable_id = fulfillments.fulfillable_id AND ' +
      'requirements.fulfillable_type = fulfillments.fulfillable_type AND ' +
      "fulfillments.fulfiller_id = #{fulfiller.id}" ).
    group( 'frameworks.id' )
  }
  scope :fulfilled, having( 'COUNT(requirements.id) <= COUNT(fulfillments.id)' )
  scope :unfulfilled, having( 'COUNT(requirements.id) > COUNT(fulfillments.id)' )
  scope :fulfilled_for, lambda { |fulfiller, perspective, role_ids|
    with_fulfillments_for(fulfiller, perspective, role_ids).fulfilled
  }
  scope :unfulfilled_for, lambda { |fulfiller, perspective, role_ids|
    with_fulfillments_for(fulfiller, perspective, role_ids).unfulfilled
  }

  def to_s; name; end

end

