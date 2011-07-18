class Requirement < ActiveRecord::Base
  attr_accessible :fulfillable_name, :perspectives, :role_id
  attr_readonly :framework_id

  belongs_to :framework, :inverse_of => :requirements
  belongs_to :fulfillable, :polymorphic => true
  belongs_to :role, :inverse_of => :requirements

  validates :framework, :presence => true
  validates :fulfillable, :presence => true
  validates :framework_id, :uniqueness =>
   { :scope => [ :fulfillable_id, :fulfillable_type, :role_id ] }
  validates :fulfillable_type, :inclusion =>
   { :in => Fulfillment::FULFILLABLE_TYPES.values.flatten }

  scope :with_inner_fulfillments, lambda {
    r = arel_table
    f = Fulfillment.arel_table
    joins('INNER JOIN fulfillments').
    where( r[:fulfillable_id].eq( f[:fulfillable_id] ).
      and( r[:fulfillable_type].eq( f[:fulfillable_type] ) ).to_sql )
  }
  scope :with_fulfillments, lambda {
    r = arel_table
    f = Fulfillment.arel_table
    joins('LEFT JOIN fulfillments ON ' +
      r[:fulfillable_id].eq( f[:fulfillable_id] ).
      and( r[:fulfillable_type].eq( f[:fulfillable_type] ) ).to_sql )
  }
  # Include only fulfillments matching specified fulfillers
  # * returns blank fulfillments as well
  scope :with_fulfillers, lambda { |*fulfillers|
    f = Fulfillment.arel_table
    sql = fulfillers.map { |fulfiller|
      '( ' +
      f[:fulfiller_type].eq( fulfiller.class.to_s ).
      and( f[:fulfiller_id].eq( fulfiller.id ) ).to_sql +
      ' )'
    }
    joins("AND ( #{sql.join(' OR ')} )")
  }
  scope :fulfilled, having( 'COUNT(requirements.id) <= COUNT(fulfillments.id)' )
  scope :unfulfilled, having( 'COUNT(requirements.id) > COUNT(fulfillments.id)' )

  scope :with_fulfillments_for, lambda { |fulfiller, perspective, role_ids|
    joins( 'LEFT JOIN fulfillments ON requirements.fulfillable_id = fulfillments.fulfillable_id AND ' +
        'requirements.fulfillable_type = fulfillments.fulfillable_type AND ' +
        "fulfillments.fulfiller_id = #{fulfiller.id}" ).
    group( 'requirements.id' ).
    where( "requirements.perspectives_mask & #{2**FundEdition::PERSPECTIVES.index(perspective)} > 0 " +
      "AND requirements.fulfillable_type IN (#{fulfiller.class.quoted_fulfillable_types}) AND " +
      ( (role_ids && !role_ids.empty?) ? "(requirements.role_id IS NULL OR " +
      "requirements.role_id IN (#{role_ids.join ','}) )" : "requirements.role_id IS NULL" ) )
  }
  scope :fulfilled_for, lambda { |fulfiller, perspective, role_ids|
    with_fulfillments_for(fulfiller, perspective, role_ids).fulfilled
  }
  scope :unfulfilled_for, lambda { |fulfiller, perspective, role_ids|
    with_fulfillments_for(fulfiller, perspective, role_ids).unfulfilled
  }

  before_validation do |r|
    r.role = nil unless Fulfillment::FULFILLABLE_TYPES['User'].include? r.fulfillable_type
  end

  def self.fulfillable_names
    Fulfillment::FULFILLABLE_TYPES.inject({}) do |memo, (fulfiller, group)|
      group.each do |member|
        member.constantize.all.each { |m| memo["#{m}"] = "#{m.class}##{m.id}" }
      end
      memo
    end
  end

  def fulfillable_name=(name)
    self.fulfillable = nil unless name
    parts = name.split('#')
    raise ArgumentError, "#{name} must have Class#Id structure" if parts.length != 2
    self.fulfillable = parts.first.constantize.find( parts.last.to_i )
  end

  def fulfillable_name
    return nil unless fulfillable
    "#{fulfillable_type}##{fulfillable_id}"
  end

  def perspectives=(perspectives)
    if perspectives.blank?
      self.perspectives_mask = 0
      return []
    end
    self.perspectives_mask = (perspectives & FundEdition::PERSPECTIVES).map { |p| 2**FundEdition::PERSPECTIVES.index(p) }.sum
  end

  def perspectives
    FundEdition::PERSPECTIVES.reject { |p| ((perspectives_mask || 0) & 2**FundEdition::PERSPECTIVES.index(p)).zero? }
  end

  def perspective=(perspective); self.perspectives = [perspective]; end

  def perspective; perspectives.first; end

  def fulfiller_type; fulfillable.class.fulfiller_type; end

  def flat_fulfillable_id; "#{fulfillable_id}_#{fulfillable_type}"; end

  def to_s
    "#{fulfillable} required for " +
    (Fulfillment::FULFILLABLE_TYPES['User'].include?(fulfillable_type) ? "#{role ? role : 'everyone'} in " : "") +
    "#{perspectives.join ', '} organization"
  end

end

