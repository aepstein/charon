class FundSource < ActiveRecord::Base
  attr_accessible :name, :framework_id, :structure_id, :contact_name,
    :contact_email, :open_at, :closed_at, :release_message, :contact_web,
    :submissions_due_at
  attr_readonly :framework_id, :structure_id

  belongs_to :organization, :inverse_of => :fund_sources
  belongs_to :structure, :inverse_of => :fund_sources
  belongs_to :framework, :inverse_of => :fund_sources
  has_many :activity_accounts, :dependent => :destroy, :inverse_of => :fund_source
  has_many :fund_requests, :dependent => :destroy, :inverse_of => :fund_source do
    def allocate_with_caps(status, club_sport, other)
      with_state( status ).includes( :organization, { :fund_items => :fund_editions } ).each do |r|
        if r.organization.club_sport?
          r.fund_items.allocate club_sport
        else
          r.fund_items.allocate other
        end
      end
    end
    def build_for( organization )
      r = self.build
      r.organization = organization
      r
    end
    def amount_for_perspective_and_status(perspective, status)
      sub = "SELECT fund_items.id FROM fund_items INNER JOIN fund_requests WHERE fund_request_id = fund_requests.id " +
            "AND fund_source_id = ? AND fund_requests.status = ?"
      FundEdition.where(:perspective => perspective).
        where( "fund_item_id IN (#{sub})", proxy_owner.id, status ).sum( 'amount' )
    end
    def fund_item_amount_for_status(status)
      sub = "SELECT fund_items.id FROM fund_items INNER JOIN fund_requests WHERE fund_request_id = fund_requests.id " +
            "AND fund_source_id = ? AND fund_requests.status = ?"
      FundItem.where( "id IN (#{sub})", proxy_owner.id, status ).sum( 'amount' )
    end
  end

  validates :name, :presence => true, :uniqueness => true
  validates :organization, :presence => true
  validates :framework, :presence => true
  validates :structure, :presence => true
  validates :contact_name, :presence => true
  validates :contact_email,
    :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :contact_web, :presence => true
  validates :open_at, :timeliness => { :type => :datetime }
  validates :closed_at, :timeliness => { :type => :datetime, :after => :open_at }
  validates :submissions_due_at,
    :timeliness => { :type => :datetime, :before => :closed_at }

  default_scope :order => 'fund_sources.name ASC'
  scope :closed, lambda { where( 'closed_at < ?', Time.zone.now ) }
  scope :open, lambda {
    where( 'open_at < :t AND closed_at > :t', :t => Time.zone.now )
  }
  scope :upcoming, lambda {
    where( 'open_at > ?', Time.zone.now )
  }
  scope :no_draft_fund_request_for, lambda { |organization|
    where(
      'fund_sources.id NOT IN (SELECT fund_source_id FROM fund_requests ' +
      'WHERE fund_requests.status IN (?) AND fund_requests.organization_id = ? )',
      %w( started completed ),
      organization.id )
  }

  def open?
    (open_at < Time.zone.now) && (closed_at > Time.zone.now)
  end

  def to_s; name; end
end

