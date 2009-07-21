class Membership < ActiveRecord::Base
  named_scope :active,
              :conditions => { :active => true }
  named_scope :in, lambda { |organization|
    { :conditions => { :organization_id => organization.id } }
  }

  belongs_to :user
  belongs_to :role
  belongs_to :registration
  belongs_to :organization
end

