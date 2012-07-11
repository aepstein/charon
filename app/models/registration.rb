class Registration < ActiveRecord::Base
  MEMBER_TYPES = %w( undergrads grads staff faculty others )
  FUNDING_SOURCES = %w( safc gpsafc sabyline gpsabyline cudept fundraising alumni )
  SEARCHABLE = [ :named ]

  attr_readonly :external_term_id, :external_id
  attr_accessor :skip_update_peers

  has_paper_trail class_name: 'SecureVersion'

  belongs_to :organization, inverse_of: :registrations
  belongs_to :registration_term, inverse_of: :registrations
  has_many :memberships, dependent: :destroy, inverse_of: :registration do
    def users
      self.map { |membership| [ membership.role, membership.user ] }
    end
  end
  has_many :users, through: :memberships, uniq: true

  default_scope order { name }

  scope :current, joins { registration_term }.where { registration_terms.current.eq( true ) }
  scope :inactive, joins { registration_term }.where { registration_terms.current.eq( false ) |
    registration_terms.current.eq( nil ) }
  scope :registered, where { registered.eq( true ) }
  scope :unapproved, where { registered.not_eq( true ) }
  scope :unmatched, where( :organization_id => nil )
  scope :named, lambda { |name| where { registrations.name.like( "%#{name}%" ) } }
  scope :min_percent_members_of_type, lambda { |percent, type|
    where( " ? <= ( number_of_#{type.to_s} * 100.0 / ( " +
        "number_of_undergrads + number_of_grads + number_of_staff + number_of_faculty + " +
        "number_of_others ) )", percent.to_i )
  }
  scope :fulfill_registration_criterion, lambda { |criterion|
    ( criterion.minimal_percentage_of_type? ? min_percent_members_of_type(
      criterion.minimal_percentage, criterion.type_of_member ) : scoped ).
    send( ( criterion.must_register? ? :registered : :scoped ) )
  }

  before_save :adopt_registration_term, :adopt_organization
  after_save :update_memberships, :update_organization, :update_peers

  # Checks if any number_of_ attributes have changed
  def number_of_members_changed?
    MEMBER_TYPES.each do |type|
      return true if send "number_of_#{type}_changed?"
    end
    false
  end

  # Checks if any number_of_members attributes were set
  def number_of_members?; member_types.any?; end

  # Member types for which value is set
  def member_types; MEMBER_TYPES.select { |type| send "number_of_#{type}?" }; end

  # Number of members
  def number_of_members
    member_types.map { |type| send "number_of_#{type}" }.inject(0,&:+)
  end

  # Assures the external term id is populated when the registration term is set
  def registration_term_id=( id )
    write_attribute :registration_term_id, id
    if registration_term && registration_term.external_id?
      self.external_term_id = regisration_term.external_id
    end
    id
  end

  def percent_members_of_type(type)
    raise ArgumentError, "#{type} is not a valid member type" unless MEMBER_TYPES.include? type
    return 0.0 unless ( number_of_members > 0 ) && send( "number_of_#{type}?" )
    ( send("number_of_#{type}") * 100.0 ) / ( number_of_members )
  end

  def funding_sources
    FUNDING_SOURCES.reject { |s| ((funding_sources_mask || 0) & 2**FUNDING_SOURCES.index(s)).zero? }
  end

  def funding_sources=(sources)
    self.funding_sources_mask = (FUNDING_SOURCES & sources).map { |s| 2**FUNDING_SOURCES.index(s) }.sum
  end

  def current?
    return false unless registration_term
    registration_term.current?
  end

  def find_or_create_organization( params={}, options={} )
    if organization.nil? || organization.new_record?
      find_or_build_organization( params, options ).save
      save
    end
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
    return Registration.unscoped.where( id: nil ) unless external_id? && persisted?
    Registration.unscoped.where { |r|
      r.external_id.eq( external_id ) & r.id.not_eq( id ) }
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
      self.organization = Organization.where { |o| o.id.in(
        Registration.unscoped.where( :external_id => external_id ).
        select { organization_id } ) }.first
    end
    true
  end

  # Update memberships to point to the organization
  # Optional force argument forces update regardless of whether organization changed
  # * updates membership framework fulfillments
  # * associates memberships with new organization, if set
  # * dissociates memberships from old organization, if new organization is nil
  def update_memberships(force = false)
    if force || organization_id_changed?
      if organization
        organization.memberships << memberships.where { |m|
          m.organization_id.eq( nil ) | m.organization_id.not_eq( organization_id )
        }
      else
        memberships.update_all( organization_id: nil )
      end
    end
    true
  end

  # Update organization:
  # * synchronize name if it has changed and this is the current registration
  # * set last_current_registration to this if this is the current registration
  # * fail silently if the organization name update fails
  # * reset organization.current_registration before fulfillment to assure
  #   current status is reflected in organization
  def update_organization
    if organization_id_changed?
      unless organization_id_was.blank?
        old_organization = Organization.find( organization_id_was )
        old_organization.association(:current_registration).reset if current?
        old_organization.update_frameworks
      end
    end
    return true unless organization && current?
    organization.last_current_registration = self
    organization.update_attributes name.to_organization_name_attributes, as: :admin
    if organization.changed?
      organization.save!
      organization.association(:current_registration).reset if current?
    end
    if organization_id_changed? || registered_changed? || number_of_members_changed?
      organization.update_frameworks
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
    peers.where { |p| p.organization_id.eq(nil) |
      p.organization_id.not_eq( organization_id ) }.each do |registration|
      registration.skip_update_peers = true
      organization.registrations << registration
    end
    true
  end

end

