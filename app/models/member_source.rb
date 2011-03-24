class MemberSource < ActiveRecord::Base
  belongs_to :organization, :inverse_of => :member_sources
  belongs_to :role, :inverse_of => :member_sources
  has_many :memberships, :dependent => :destroy, :inverse_of => :member_source
  has_many :users, :through => :memberships

  validates_presence_of :organization
  validates_presence_of :role
  validates_numericality_of :minimum_votes, :integer_only => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :external_committee_id, :integer_only => true,
    :greater_than => 0

end

