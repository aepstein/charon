class FundGrant < ActiveRecord::Base
  belongs_to :organization
  belongs_to :fund_source

  validates :organization, :presence => true
  validates :fund_source, :presence => true
  validates :fund_source_id, :uniqueness => { :scope => :organization_id }
end

