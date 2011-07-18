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

  scope :with_requirements_for, lambda { |perspective, organization, user|
    role_ids = organization.roles.
      where( :name.in => Role.names_for_perspective( perspective ),
        :memberships => { :user_id => user.id } ).map(&:id)
    joins { requirements.outer }.
    joins( "AND requirements.framework_id = frameworks.id " +
      "AND (requirements.perspectives_mask & " +
      "#{2**FundEdition::PERSPECTIVES.index(perspective)} > 0 ) AND " +
      "( requirements.role_id IS NULL" +
      ( role_ids.empty? ? "" : " OR requirements.role_id IN (#{role_ids.join ','})" ) +
      " )"
    )
  }
  scope :with_fulfillments_for, lambda { |perspective, organization, user|
    with_requirements_for( perspective, organization, user).
    merge( Requirement.unscoped.with_fulfillments.with_fulfillers( organization, user ) )
  }
  scope :fulfilled_for, lambda { |perspective, organization, user|
    with_fulfillments_for( perspective, organization, user ).
    merge( Requirement.fulfilled ).group("frameworks.id")
  }
  scope :unfulfilled_for, lambda { |perspective, organization, user|
    with_fulfillments_for( perspective, organization, user ).
    merge( Requirement.unfulfilled ).group("frameworks.id")
  }


  def to_s; name; end

end

