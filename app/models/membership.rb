class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :registration
  belongs_to :organization
end

