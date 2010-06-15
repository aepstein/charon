class Registration < ActiveRecord::Base
  MEMBER_TYPES = %w( undergrads grads staff faculty others )
  FUNDING_SOURCES = %w( safc gpsafc sabyline gpsabyline cudept fundraising alumni )
  default_scope :order => "registrations.name ASC, registrations.parent_id DESC"
  named_scope :active, :joins => 'LEFT JOIN registrations AS r ON registrations.id = r.parent_id',
   :conditions => 'r.id IS NULL'
  named_scope :unmatched, :conditions => { :organization_id => nil }
  named_scope :named, lambda { |name|
    { :conditions => [ "registrations.name LIKE '%?%'", name ] }
  }
  named_scope :min_percent_members_of_type, lambda { |percent, type|
    { :conditions => [ " ? <= ( number_of_#{type.to_s} * 100.0 / ( " +
        "number_of_undergrads + number_of_grads + number_of_staff + number_of_faculty + " +
        "number_of_others ) )", percent.to_i] }
  }

  acts_as_tree

  belongs_to :organization
  belongs_to :registration_term, :foreign_key => :external_term_id, :primary_key => :external_id
  has_many :memberships, :dependent => :destroy do
    def users
      self.map { |membership| [ membership.role, membership.user ] }
    end
  end
  has_many :users, :through => :memberships, :uniq => true

  validates_uniqueness_of :id

  before_save :verify_parent_exists, :update_organization
  after_save :synchronize_memberships, 'Fulfillment.fulfill organization if organization && active?'
  after_update 'Fulfillment.unfulfill organization if organization && active?'

  def registration_criterions
    RegistrationCriterion.all.inject([]) do |memo, criterion|
      memo << criterion if fulfills? criterion
      memo
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

  # Eliminates reference to parent registration if registration is not in
  # database.
  def verify_parent_exists
    parent_id = nil unless Registration.exists?(parent_id)
  end

  def update_organization
    organization.update_attributes( name.to_organization_name_attributes ) if organization_id? && active?
  end

  def percent_members_of_type(type)
    self.send("number_of_#{type.to_s}") * 100.0 / ( number_of_undergrads +
      number_of_grads + number_of_staff + number_of_faculty + number_of_others )
  end

  def self.find_or_create_by_external_registration( e )
    registration = external_id_equals( e.org_id ).external_term_id_equals( e.term_id ).first || Registration.new
    unless registration.new_record?
      registration.organization = Organization.registration_external_id_equals( e.org_id ).first
    end
    registration.attributes = e.import_attributes_for_local
    registration
  end

  def find_or_create_organization( params=nil )
    find_or_build_organization( params ).save if organization.nil? || organization.new_record?
    organization
  end

  def find_or_build_organization( params=nil )
    return organization unless organization.nil?
    params = Hash.new if params.nil?
    build_organization( params.merge( name.to_organization_name_attributes ) )
  end

  def to_s; name; end

end

