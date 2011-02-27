class MemberSource < ActiveRecord::Base
  belongs_to :organization
  belongs_to :role
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships

  validates_presence_of :organization
  validates_presence_of :role
  validates_numericality_of :minimum_votes, :integer_only => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :external_committee_id, :integer_only => true,
    :greater_than => 0

end

