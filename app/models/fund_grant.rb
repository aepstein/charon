class FundGrant < ActiveRecord::Base
  SEARCHABLE = [ :fund_source_name_contains, :organization_name_contains ]

  attr_accessible :fund_source_id
  attr_readonly :organization_id, :fund_source_id

  belongs_to :organization, :inverse_of => :fund_grants
  belongs_to :fund_source, :inverse_of => :fund_grants

  has_many :fund_requests, :inverse_of => :fund_grant, :dependent => :destroy do
    # Builds a first request, inferring request type from those that are
    # allowed for the first in upcoming queues
    # * will leave fund_request_type blank if owner has no fund source
    #   from which to make the inference
    def build_first
      request = build
      return request if @association.owner.fund_source.blank?
      request.fund_request_type = @association.owner.fund_source.
        fund_request_types.upcoming.allowed_for_first.first
    end
  end
  has_many :fund_items, :inverse_of => :fund_grant, :dependent => :destroy

  has_many :users, :through => :organization do
    # Retrieves users associated with a perspective for the grant
    def for_perspective( perspective )
      role_names = case perspective.to_s
      when FundEdition::PERSPECTIVES.first
        Role::REQUESTOR
      else
        Role::REVIEWER
      end
      User.joins( :memberships ).merge( @association.owner.send(perspective).
      memberships.active.joins( :role ).
      merge( Role.where( :name.in => role_names ) ) )
    end
  end

  has_paper_trail :class_name => 'SecureVersion'

  scope :ordered, includes { [ organization, fund_source ] }.
    order( 'fund_sources.name ASC, organizations.last_name ASC, organizations.first_name ASC' )
  scope :current, lambda { joins(:fund_source).merge( FundSource.unscoped.current ) }
  scope :closed, lambda { joins(:fund_source).merge( FundSource.unscoped.closed ) }
  scope :no_draft_fund_request, where { id.not_in(
    FundRequest.unscoped.draft.select { fund_grant_id } ) }
  scope :organization_name_contains, lambda { |name|
    joins { organization }.merge Organization.name_contains( name )
  }
  scope :fund_source_name_contains, lambda { |name|
    joins { fund_source }.merge FundSource.where( :name.like => name )
  }

  paginates_per 10

  validates :organization, :presence => true
  validates :fund_source, :presence => true
  validates :fund_source_id, :uniqueness => { :scope => :organization_id }
  validates :released_at,
    :timeliness => { :type => :datetime, :allow_blank => true }

  # Organization associated with this grant in requestor perspective
  def requestor; organization; end

  # Organization associated with this grant in reviewer perspective
  def reviewer; fund_source ? fund_source.organization : nil; end

  # Return unfulfilled requirements for the grant that pertain to users
  # * must supply users
  # * considers only requirements for first perspective in which user has roles
  # * returns hash { organization => [ req1, req2 ], user => [ req3 ] }
  def unfulfilled_requirements_for(*users)
    users.flatten.inject({}) do |memo, user|
      FundEdition::PERSPECTIVES.each do |perspective|
        organization = send(perspective)
        requirements = fund_source.framework.requirements.unfulfilled_for( perspective,
          organization, user )
        if requirements.length > 0
          requirements.each do |requirement|
            fulfiller = if User.fulfillable_types.include? requirement.fulfillable_type
              user
            else
              organization
            end
            memo[fulfiller] ||= Array.new
            memo[fulfiller] << requirement
          end
          break
        end
      end
      memo
    end.each { |k, v| v.uniq! }
  end

  # What is the perspective of the user or organization with respect to this
  # grant?
  # * fulfiller must be a User or Organization
  def perspective_for( fulfiller )
    case fulfiller.class.to_s.to_sym
    when :User
      return 'requestor' if fulfiller.roles.requestor_in? organization
      return 'reviewer' if fulfiller.roles.reviewer_in? fund_source.organization
    when :Organization
      return 'requestor' if fulfiller == requestor
      return 'reviewer' if fulfiller == reviewer
    else
      raise ArgumentError, "argument cannot be of class #{fulfiller.class}"
    end
    nil
  end

  delegate :require_requestor_recipients!, :to => :organization

end

