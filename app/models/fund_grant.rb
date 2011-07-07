class FundGrant < ActiveRecord::Base

  attr_accessible :fund_source_id
  attr_readonly :organization_id, :fund_source_id

  belongs_to :organization, :inverse_of => :fund_grants
  belongs_to :fund_source, :inverse_of => :fund_grants

  has_many :fund_requests, :inverse_of => :fund_grant, :dependent => :destroy
  has_many :fund_items, :inverse_of => :fund_grant, :dependent => :destroy

  has_paper_trail :class_name => 'SecureVersion'

  validates :organization, :presence => true
  validates :fund_source, :presence => true
  validates :fund_source_id, :uniqueness => { :scope => :organization_id }
  validates :released_at,
    :timeliness => { :type => :datetime, :allow_blank => true }
end

