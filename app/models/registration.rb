class Registration < ActiveRecord::Base
  MEMBER_TYPES = %w( undergrads grads staff faculty others )
  FUNDING_SOURCES = %w( safc gpsafc sabyline gpsabyline cudept fundraising alumni )
  SEARCHABLE = [ :named ]

  has_paper_trail :class_name => 'SecureVersion'

  belongs_to :organization, :inverse_of => :registrations
  belongs_to :registration_term, :inverse_of => :registrations
  has_many :memberships, :dependent => :destroy, :inverse_of => :registration do
    def users
      self.map { |membership| [ membership.role, membership.user ] }
    end
  end
  has_many :users, :through => :memberships, :uniq => true

  default_scope :order => "registrations.name ASC"

  scope :active, joins { registration_term }.where { registration_terms.current.eq( true ) }
  scope :inactive, joins { registration_term }.where { registration_terms.current.eq( false ) |
    registration_terms.current.eq( nil ) }
  scope :registered, where { registered.eq( true) }
  scope :unmatched, where( :organization_id => nil )
  scope :named, lambda { |name| where { registrations.name.like( "%#{name}%" ) } }
  scope :min_percent_members_of_type, lambda { |percent, type|
    where( " ? <= ( number_of_#{type.to_s} * 100.0 / ( " +
        "number_of_undergrads + number_of_grads + number_of_staff + number_of_faculty + " +
        "number_of_others ) )", percent.to_i )
  }

  before_save :adopt_registration_term, :adopt_organization
  after_save :update_organization, :update_memberships, :update_peers

  attr_accessor :skip_update_peers

  # Assures the external term id is populated when the registration term is set
  def registration_term_id=( id )
    write_attribute :registration_term_id, id
    if registration_term && registration_term.external_id?
      self.external_term_id = regisration_term.external_id
    end
    id
  end

  # Return criterions fulfilled by this registration
  # * can only fulfill criterions if the registration is current
  def registration_criterions
    return [] unless active?
    RegistrationCriterion.all.inject([]) do |memo, criterion|
      fulfills?( criterion ) ? memo << criterion : memo
    end
  end

  def fulfills?(criterion)
    return false if criterion.must_register? && !registered?
    percent_members_of_type(criterion.type_of_member) >= criterion.minimal_percentage
  end

  def percent_members_of_type(type)
    ( send('number_of_' + type) * 100.0 ) / ( number_of_undergrads +
      number_of_grads + number_of_staff + number_of_faculty + number_of_others )
  end

  def funding_sources
    FUNDING_SOURCES.reject { |s| ((funding_sources_mask || 0) & 2**FUNDING_SOURCES.index(s)).zero? }
  end

  def funding_sources=(sources)
    self.funding_sources_mask = (FUNDING_SOURCES & sources).map { |s| 2**FUNDING_SOURCES.index(s) }.sum
  end

  def active?
    return false unless registration_term
    registration_term.current?
  end

  alias :current? :active?

  def percent_members_of_type(type)
    self.send("number_of_#{type.to_s}") * 100.0 / ( number_of_undergrads +
      number_of_grads + number_of_staff + number_of_faculty + number_of_others )
  end

  def find_or_create_organization( params={}, options={} )
    find_or_build_organization( params, options ).save if organization.nil? || organization.new_record?
    organization
  end

  def find_or_build_organization( params={}, options={} )
    return organization unless organization.nil?
    params ||= Hash.new
    options ||= Hash.new
    options[:as] ||= :admin
    build_organization( params.merge( name.to_organization_name_attributes ), options )
  end

  def to_s; name; end

  def peers
    return Registration.unscoped.where( :id => nil ) unless external_id? && persisted?
    Registration.unscoped.where { external_id == my { external_id } }.
      where { id != my { id } }
  end

  private

  # Automatically match to registration_term based on external term id if record
  # is not already matched to such a term
  def adopt_registration_term
    if external_term_id? && ( registration_term.blank? || registration_term.external_id != external_term_id )
      self.registration_term = RegistrationTerm.find_by_external_id( external_term_id )
    end
    true
  end

  # Automatically match to organization based on external id if record is unmatched
  # by checking if another organization is matched by the same external id
  def adopt_organization
    if external_id? && organization.blank?
      self.organization = Organization.joins { registrations }.merge(
        Registration.unscoped.where( :external_id => external_id ) ).
        readonly(false).first
    end
    true
  end

  # Update organization:
  # * reset registrations collection so saved changes are reloaded in the collection
  # ** this reset assures fulfill and unfulfill will work off of updated registration
  # * synchronize name if it has changed and this is the current registration
  # * set last_current_registration to this if this is the current registration
  # * fulfill and unfulfill organization as appropriate
  # * fail silently if the organization name update fails
  def update_organization
    return true unless organization
    organization.association(:registrations).reset
    if current?
      if organization.last_current_registration != self
        organization.last_current_registration = self
        organization.save!
      end
      organization.update_attributes name.to_organization_name_attributes
      organization.fulfillments.fulfill!
    end
    organization.fulfillments.unfulfill!
    true
  end

  # Update memberships to point to the organization
  def update_memberships
    if organization && organization_id_changed?
      organization.memberships << memberships.where(
        memberships.arel_table[:organization_id].eq(nil).
        or( memberships.arel_table[:organization_id].not_eq( organization_id ) ) )
    end
    true
  end

  # Match peers with same external id but different or blank organization id
  # to the organization id of this registration
  # * skip if no external_id or matching organization is present for this record
  # * exclude this registration
  # * set flag to prevent recursion
  def update_peers
    if skip_update_peers || external_id.blank? || organization.blank?
      self.skip_update_peers = false
      return true
    end
    peers.where( peers.arel_table[:organization_id].eq(nil).
      or( peers.arel_table[:organization_id].not_eq( organization_id ) )
    ).each do |registration|
      registration.skip_update_peers = true
      organization.registrations << registration
    end
    true
  end

end

