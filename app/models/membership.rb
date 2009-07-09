class Membership < ActiveRecord::Base
  named_scope :active,
              :conditions => { :active => true }

  belongs_to :user
  belongs_to :role
  belongs_to :registration
  belongs_to :organization
end
