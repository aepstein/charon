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

  # Includes only frameworks for which requirements are fulfilled for
  # given perspective and subject(s)
  scope :fulfilled_for, lambda { |perspective, *subjects|
    unfulfilled_requirements = Requirement.unscoped.
      unfulfilled_for( perspective, subjects ).select { framework_id }
    where { id.not_in( unfulfilled_requirements ) }
  }
  # Includes only frameworks for which requirements are not fulfilled for
  # given perspective and subject(s)
  scope :unfulfilled_for, lambda { |perspective, *subjects|
    unfulfilled_requirements = Requirement.unscoped.
      unfulfilled_for( perspective, subjects ).select { framework_id }
    where { id.in( unfulfilled_requirements ) }
  }

  def to_s; name; end

end

