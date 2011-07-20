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
    f = Fulfillment.arel_table
    joins('INNER JOIN fulfillments').
    where { fulfillable_id.eq( f[:fulfillable_id] ) &
      fulfillable_type.eq( f[:fulfillable_type] ) }
  }
  scope :with_outer_fulfillments, lambda {
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
    sql = fulfillers.flatten.map { |fulfiller|
      '( ' +
      f[:fulfiller_type].eq( fulfiller.class.to_s ).
      and( f[:fulfiller_id].eq( fulfiller.id ) ).to_sql +
      ' )'
    }
    joins("AND ( #{sql.join(' OR ')} )")
  }
  scope :fulfilled, having( 'COUNT(requirements.id) <= COUNT(fulfillments.id)' )
  scope :unfulfilled, having( 'COUNT(requirements.id) > COUNT(fulfillments.id)' )

  # Limits examined requirements to a perspective
  scope :for_perspective, lambda { |perspective|
    where( "? & perspectives_mask > 0",
      2**FundEdition::PERSPECTIVES.index(perspective.to_s) )
  }
  # Limits examined requirements to a single subject
  # * subject must be a user or organization
  # * excludes role-specific requirements or requirements subject cannot fulfill
  #   directly
  scope :for_subject, lambda { |subject|
    where { role_id.eq( nil ) & fulfillable_type.in( subject.fulfillable_types ) }
  }
  # Limits examined requirements to given organization/user pair
  # * chooses requirements which are not specific to a role or which are
  #   specific to a role held by the user in the specified perspective
  scope :for_subjects, lambda { |perspective, organization, user|
    role_ids = Role.for_perspective( perspective, organization, user ).
      except(:select,:order).select { id }
    where { role_id.eq( nil ) | role_id.in( role_ids ) }
  }
  # Retrieves associated requirement information
  # * chooses appropriate scope to use based on number of arguments
  scope :for_perspective_and_subjects, lambda { |perspective, *args|
    subjects = args.flatten
    scope = with_outer_fulfillments.with_fulfillers( subjects ).
      for_perspective( perspective )
    case subjects.length
    when 1
      scope.for_subject subjects.first
    when 2
      scope.for_subjects perspective, subjects.first, subjects.last
    else
      raise ArgumentError( "must have either organization/user or organization, user")
    end
  }
  # Includes only requirements that are fulfilled for
  # given perspective and subject(s)
  scope :fulfilled_for, lambda { |perspective, *subjects|
    for_perspective_and_subjects( perspective, subjects ).fulfilled.
      group { id }
  }
  # Includes only frameworks for which requirements are not fulfilled for
  # given perspective and subject(s)
  scope :unfulfilled_for, lambda { |perspective, *subjects|
    for_perspective_and_subjects( perspective, subjects ).unfulfilled.
      group { id }
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
    FundEdition::PERSPECTIVES.reject { |p|
      ((perspectives_mask || 0) & 2**FundEdition::PERSPECTIVES.index(p)).zero?
    }
  end

  def perspective=(perspective); self.perspectives = [perspective]; end

  def perspective; perspectives.first; end

  def fulfiller_type; fulfillable.class.fulfiller_type; end

  def flat_fulfillable_id; "#{fulfillable_id}_#{fulfillable_type}"; end

  def to_s(format = nil)
    case format
    when :condition
      fulfillable.to_s :requirement
    else
      "#{fulfillable} required for " +
      (Fulfillment::FULFILLABLE_TYPES['User'].include?(fulfillable_type) ? "#{role ? role : 'everyone'} in " : "") +
      "#{perspectives.join ', '} organization"
    end
  end

end

