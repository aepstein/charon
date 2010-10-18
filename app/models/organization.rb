class Organization < ActiveRecord::Base
  include Fulfiller

  has_many :activity_reports, :dependent => :destroy
  has_many :university_accounts, :dependent => :destroy
  has_many :users, :through => :memberships, :conditions => ['memberships.active = ?', true]
  has_many :registrations do
    def current
      self.active.first
    end
  end
  has_many :inventory_items, :dependent => :destroy
  has_many :memberships
  has_many :roles, :through => :memberships do
    def user_id_equals( id )
      scoped( :conditions => [ 'memberships.user_id = ?', id ] )
    end
    def ids_for_user( user )
      user_id_equals( user.id ).all.map(&:id)
    end
  end
  has_many :bases do
    def requestable
      Basis.open.no_draft_request_for( proxy_owner )
    end
  end
  has_many :requests do
    def creatable
      proxy_owner.bases.requestable.map { |basis| build( :basis => basis ) }
    end
  end
  has_many :fulfillments, :as => :fulfiller, :dependent => :delete_all

  before_validation :format_name

  default_scope :order => 'organizations.last_name ASC, organizations.first_name ASC'
  scope_procedure :name_like, lambda { |name| first_name_like_or_last_name_like( name ) }

  after_save :update_registrations

  validates_presence_of :last_name
  validates_uniqueness_of :last_name, :scope => :first_name

  # Adopt registrations (and consequently memberships where appropriate)
  def update_registrations
    unless registrations.length == 0
      Registration.external_id_equals_any( registrations.map(&:external_id).uniq
      ).organization_id_null.each do |registration|
        registration.organization = self
        registration.save
      end
    end
  end

  def registration_criterions
    return [] unless registrations.current
    registrations.current.registration_criterions
  end

  def registration_criterion_ids
    registration_criterions.map { |criterion| criterion.id }
  end

  def registered?
    return false if registrations.current.blank?
    registrations.current.registered?
  end

  def independent?
    return false if registrations.current.blank?
    registrations.current.independent?
  end

  def name(format=nil)
    case format
    when :last_first
      "#{last_name}, #{first_name}"
    else
      first_name.blank? ? last_name : "#{first_name} #{last_name}"
    end
  end

  def format_name
    return unless last_name
    self.first_name = "" unless first_name.class == String
    while match = last_name.match(/\A(Cornell|The|An|A)\s+(.*)\Z/) do
      self.first_name = "#{first_name} #{match[1]}".strip
      self.last_name = match[2]
    end
  end

  def to_s
    name
  end
end

