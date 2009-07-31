class Membership < ActiveRecord::Base
  named_scope :active,
              :conditions => { :active => true }
  named_scope :in, lambda { |organization_ids|
    { :conditions => { :organization_id => organization_ids } }
  }

  belongs_to :user
  belongs_to :role
  belongs_to :registration
  belongs_to :organization

  validates_presence_of :user
  validates_presence_of :role
  validate :must_have_registration_or_organization

  def must_have_registration_or_organization
    errors.add_to_base( 'Must have a registration or organization.'
    ) unless registration || organization
  end
end

