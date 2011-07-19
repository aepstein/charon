class Framework < ActiveRecord::Base
  attr_accessible :name, :requirements_attributes

  has_many :approvers, :inverse_of => :framework
  has_many :requirements, :inverse_of => :framework
  has_many :fund_sources, :inverse_of => :framework

  validates :name, :presence => true, :uniqueness => true

  accepts_nested_attributes_for :requirements,
    :reject_if => proc { |attributes| attributes['fulfillable_name'].blank? },
    :allow_destroy => true

  default_scope order( 'frameworks.name ASC' )

  # Retrieves associated requirement information for frameworks
  # * chooses appropriate scope to use based on number of arguments
  scope :with_requirements_for, lambda { |perspective, *args|
    subjects = args.flatten
    scope = joins { requirements.outer }.
      with_requirements_for_perspective( perspective )
    case subjects.length
    when 1
      scope.with_requirements_for_subject subjects.first
    when 2
      scope.with_requirements_for_subjects perspective, subjects.first, subjects.last
    else
      raise ArgumentError( "must have either organization/user or organization, user")
    end
  }
  # Limits examined requirements to a perspective
  scope :with_requirements_for_perspective, lambda { |perspective|
    joins( "AND (requirements.perspectives_mask & " +
      "#{2**FundEdition::PERSPECTIVES.index(perspective)} > 0 )" )
  }
  # Limits examined requirements to a single subject
  # * subject must be a user or organization
  # * excludes role-specific requirements or requirements subject cannot fulfill
  #   directly
  scope :with_requirements_for_subject, lambda { |subject|
    joins( "AND requirements.role_id IS NULL AND " +
      "requirements.fulfillable_type IN (#{subject.quoted_fulfillable_types})" )
  }
  # Limits examined requirements to given organization/user pair
  # * chooses requirements which are not specific to a role or which are
  #   specific to a role held by the user in the specified perspective
  scope :with_requirements_for_subjects, lambda { |perspective, organization, user|
    role_ids = organization.roles.where {
      name.in( Role.names_for_perspective( my { perspective } ) ) &
      memberships.user_id.eq( my { user.id } ) }.
      except(:select,:order).select("roles.id").to_sql
    joins( "AND ( requirements.role_id IS NULL OR requirements.role_id IN " +
      "(#{role_ids}) )" )
  }
  # Examines both requirements and fulfillments
  # * limits fulfillments to the subjects provided
  scope :with_fulfillments_for, lambda { |perspective, *subjects|
    with_requirements_for( perspective, subjects).
    merge( Requirement.unscoped.with_outer_fulfillments.
      with_fulfillers( subjects.flatten ) )
  }
  # Includes only frameworks for which requirements are fulfilled for
  # given perspective and subject(s)
  scope :fulfilled_for, lambda { |perspective, *subjects|
    with_fulfillments_for( perspective, subjects ).
    merge( Requirement.fulfilled ).group("frameworks.id")
  }
  # Includes only frameworks for which requirements are not fulfilled for
  # given perspective and subject(s)
  scope :unfulfilled_for, lambda { |perspective, *subjects|
    with_fulfillments_for( perspective, subjects ).
    merge( Requirement.unfulfilled ).group("frameworks.id")
  }

  def to_s; name; end

end

