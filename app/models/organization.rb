class Organization < ActiveRecord::Base
  has_many :registrations
  has_many :memberships
  has_and_belongs_to_many :requests
  before_validation :format_name

  def name
    first_name.nil? || first_name.empty? ? last_name : "#{first_name} #{last_name}"
  end

  def self.find_or_create_by_registration(registration)
    return registration.organization unless registration.organization.nil?
    organization = Organization.create(registration.attributes_for_organization)
    organization.registrations << registration
    organization
  end

  def format_name
    while match = last_name.match(/\A(Cornell|The|An|A)\s+(.*)\Z/) do
      self.first_name = "#{first_name} #{match[1]}".strip
      self.last_name = match[2]
    end
  end

  def safc_eligible?
    return false if registrations.active.first.nil?
    registrations.active.first.safc_eligible?
  end

  def gpsafc_eligible?
    return false if registrations.active.first.nil?
    registrations.active.first.gpsafc_eligible?
  end

  def to_s
    name
  end
end

