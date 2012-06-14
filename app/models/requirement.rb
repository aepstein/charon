# Note: Requirement class does not call necessary callbacks to update
# memberships that might be affected.  This should not be a problem so long
# as requirements are always modified at the same time as the framework.
# With the accepts_nested_attributes_for settings, this should always be the case.
class Requirement < ActiveRecord::Base
  FULFILLABLE_TYPES = {
    'User' => %w( Agreement UserStatusCriterion ),
    'Registration' => %w( RegistrationCriterion )
  }

  attr_accessible :fulfillable_name, :perspectives, :role_id
  attr_readonly :framework_id

  belongs_to :framework, inverse_of: :requirements
  belongs_to :fulfillable, polymorphic: true
  belongs_to :role, inverse_of: :requirements

  validates :framework, presence: true
  validates :fulfillable, presence: true
  validates :framework_id, uniqueness: { scope: [ :fulfillable_id,
    :fulfillable_type, :role_id ] }
  validates :fulfillable_type, inclusion:
   { in: FULFILLABLE_TYPES.values.flatten }


  scope :all_roles, where( role_id: nil )
  scope :single_role, where { role_id.not_eq( nil ) }
  # Find all requirements a membership fulfills
  # * include role-specific requirements that don't apply to this membership
  scope :fulfilled_by, lambda { |membership|
    where { |r|
      ( r.role_id.not_eq( nil ) & r.role_id.not_eq( membership.role_id ) ) |
      ( r.fulfillable_type.eq( 'UserStatusCriterion' ) &
      r.fulfillable_id.in( UserStatusCriterion.fulfilled_by( membership.user ).select { id } ) ) |
      ( r.fulfillable_type.eq( 'Agreement' ) &
      r.fulfillable_id.in( Agreement.fulfilled_by( membership.user ).select { id } ) ) |
      ( r.fulfillable_type.eq('RegistrationCriterion' ) &
      r.fulfillable_id.in( RegistrationCriterion.fulfilled_by( membership.registration ).select { id } ) )
    }
  }
  scope :unfulfilled_by, lambda { |membership|
    where { |r| r.id.not_in( Requirement.fulfilled_by( membership ).select { id } ) }
  }

  def self.fulfillable_names
    FULFILLABLE_TYPES.inject({}) do |memo, (fulfiller, group)|
      group.each do |member|
        member.constantize.all.each { |m| memo["#{m}"] = "#{m.class}##{m.id}" }
      end
      memo
    end
  end

  def fulfillment_criterion( memberships )
    case fulfillable.class.fulfiller_type
    when 'User'
      memberships.user_id.in( User.unscoped.
        send( :fulfill, fulfillable ).select { id } )
    else
      memberships.organization_id.in( Organization.unscoped.
        send( :fulfill, fulfillable ).select { id } )
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

  def fulfiller_type; fulfillable.class.fulfiller_type; end

  def flat_fulfillable_id; "#{fulfillable_id}_#{fulfillable_type}"; end

  def to_s(format = nil)
    case format
    when :condition
      fulfillable.to_s :requirement
    else
      "#{fulfillable} required for #{role ? role : 'everyone'} in organization"
    end
  end

end

