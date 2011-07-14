class FundGrant < ActiveRecord::Base

  attr_accessible :fund_source_id
  attr_readonly :organization_id, :fund_source_id

  belongs_to :organization, :inverse_of => :fund_grants
  belongs_to :fund_source, :inverse_of => :fund_grants

  has_many :fund_requests, :inverse_of => :fund_grant, :dependent => :destroy
  has_many :fund_items, :inverse_of => :fund_grant, :dependent => :destroy

  # TODO - need :through => :organization, but need Rails 3.1 to implement
  has_many :users do
    # Retrieves users associated with a perspective for the grant
    def for_perspective( perspective )
      role_names = case perspective
      when FundEdition::PERSPECTIVES.first
        Role::REQUESTOR
      else
        Role::REVIEWER
      end
      User.joins( :memberships ).merge( proxy_owner.send(perspective).
      memberships.active.joins( :role ).
      merge( Role.where( :name.in => role_names ) ) )
    end
  end

  has_paper_trail :class_name => 'SecureVersion'

  default_scope includes( :organization, :fund_source ).
    order( 'fund_sources.name ASC, organizations.last_name ASC, organizations.first_name ASC' )
  scope :open, lambda { joins(:fund_source).merge( FundSource.unscoped.open ) }
  scope :closed, lambda { joins(:fund_source).merge( FundSource.unscoped.closed ) }

  validates :organization, :presence => true
  validates :fund_source, :presence => true
  validates :fund_source_id, :uniqueness => { :scope => :organization_id }
  validates :released_at,
    :timeliness => { :type => :datetime, :allow_blank => true }

  # Organization associated with this grant in requestor perspective
  def requestor; organization; end

  # Organization associated with this grant in reviewer perspective
  def reviewer; fund_source ? fund_source.organization : nil; end

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

  # What requirements must the user or organization fulfill in order to have
  # privileges for this grant?
  # * fulfiller must be a User or Organization
  def unfulfilled_requirements_for( fulfiller )
    perspective = perspective_for( fulfiller )
    return [] unless perspective && fund_grant && fund_grant.fund_source
    case fulfiller.class.to_s.to_sym
    when :User
      fund_grant.fund_source.framework.requirements.unfulfilled_for( fulfiller, perspective,
        fulfiller.roles.ids_in_perspective( send(perspective), perspective ) )
    when :Organization
      fund_grant.fund_source.framework.requirements.unfulfilled_for( fulfiller, perspective, [] )
    else
      raise ArgumentError, "argument cannot be of class #{fulfiller.class}"
    end
  end

end

