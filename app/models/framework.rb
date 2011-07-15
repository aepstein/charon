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

  # Includes requirements and fulfillments matching one or more fulfillers
  # * fulfillers: either a fulfiller object or an array of them
  # * perspective: perspective to limit to
  # * role_ids: specify role for role-limited requirements
  # * if role_ids is not supplied, but organization and user are supplied,
  #   the role_ids will be inferred based upon the user's role in the
  #   organization
  scope :with_fulfillments_for, lambda { |fulfillers, perspective, role_ids|
    fulfillers = fulfillers.is_a?(Array) ? fulfillers : [ fulfillers ]

    organizations = fulfillers.select { |fulfiller| fulfiller.is_a? Organization }
    users = fulfillers.select { |fulfiller| fulfiller.is_a? User }

    perspective_roles = if perspective == FundEdition::PERSPECTIVES.first
      Role::REQUESTOR
    else
      Role::REVIEWER
    end

    if role_ids.empty?
      role_ids = organizations.map(&:roles).map { |roles|
        users.map { |user|
          roles.where( :memberships => { :user_id => user.id },
            :name.in => perspective_roles ).map(&:id)
        }
      }.flatten.uniq
    end

    requirement_criteria = ( fulfillers ).
    map(&:class).map(&:fulfillable_types).flatten.uniq.
    map { |type| connection.quote type }.join(',')

    fulfiller_criteria = ( fulfillers ).map { |fulfiller|
      "(fulfillments.fulfiller_id = #{fulfiller.id} AND " +
      "fulfillments.fulfiller_type = #{connection.quote fulfiller.class.to_s})"
    }.join(' OR ')

    role_criteria = if role_ids && !role_ids.empty?
      "(requirements.role_id IS NULL OR requirements.role_id IN " +
      "(#{role_ids.join ','}) )"
    else
      "requirements.role_id IS NULL"
    end

    joins( 'LEFT JOIN requirements ON requirements.framework_id = frameworks.id ' +
      "AND requirements.fulfillable_type IN (#{requirement_criteria}) " +
      "AND #{role_criteria} AND (requirements.perspectives_mask & "+
      "#{2**FundEdition::PERSPECTIVES.index(perspective)}) > 0 " +
      'LEFT JOIN fulfillments ON requirements.fulfillable_id = ' +
      'fulfillments.fulfillable_id AND requirements.fulfillable_type = ' +
      "fulfillments.fulfillable_type AND " +
      "( #{fulfiller_criteria} )" ).
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

