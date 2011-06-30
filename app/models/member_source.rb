class MemberSource < ActiveRecord::Base
  belongs_to :organization, :inverse_of => :member_sources
  belongs_to :role, :inverse_of => :member_sources
  has_many :memberships, :dependent => :destroy, :inverse_of => :member_source
  has_many :users, :through => :memberships

  validates :organization, :presence => true
  validates :role, :presence => true
  validates :minimum_votes,
    :numericality => { :integer_only => true, :greater_than_or_equal_to => 0 }
  validates :external_committee_id,
    :numericality => { :integer_only => true, :greater_than => 0 }

end

