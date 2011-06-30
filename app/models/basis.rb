class Basis < ActiveRecord::Base
  attr_accessible :name, :framework_id, :structure_id, :contact_name,
    :contact_email, :open_at, :closed_at, :release_message, :contact_web,
    :submissions_due_at
  attr_readonly :framework_id, :structure_id

  belongs_to :organization, :inverse_of => :bases
  belongs_to :structure, :inverse_of => :bases
  belongs_to :framework, :inverse_of => :bases
  has_many :activity_accounts, :dependent => :destroy, :inverse_of => :basis
  has_many :requests, :dependent => :destroy, :inverse_of => :basis do
    def allocate_with_caps(status, club_sport, other)
      with_state( status ).includes( :organization, { :items => :editions } ).each do |r|
        if r.organization.club_sport?
          r.items.allocate club_sport
        else
          r.items.allocate other
        end
      end
    end
    def build_for( organization )
      r = self.build
      r.organization = organization
      r
    end
    def amount_for_perspective_and_status(perspective, status)
      sub = "SELECT items.id FROM items INNER JOIN requests WHERE request_id = requests.id " +
            "AND basis_id = ? AND requests.status = ?"
      Edition.where(:perspective => perspective).
        where( "item_id IN (#{sub})", proxy_owner.id, status ).sum( 'amount' )
    end
    def item_amount_for_status(status)
      sub = "SELECT items.id FROM items INNER JOIN requests WHERE request_id = requests.id " +
            "AND basis_id = ? AND requests.status = ?"
      Item.where( "id IN (#{sub})", proxy_owner.id, status ).sum( 'amount' )
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

  default_scope :order => 'bases.name ASC'
  scope :closed, lambda { where( 'closed_at < ?', Time.zone.now ) }
  scope :open, lambda {
    where( 'open_at < :t AND closed_at > :t', :t => Time.zone.now )
  }
  scope :upcoming, lambda {
    where( 'open_at > ?', Time.zone.now )
  }
  scope :no_draft_request_for, lambda { |organization|
    where(
      'bases.id NOT IN (SELECT basis_id FROM requests ' +
      'WHERE requests.status IN (?) AND requests.organization_id = ? )',
      %w( started completed ),
      organization.id )
  }

  def open?
    (open_at < Time.zone.now) && (closed_at > Time.zone.now)
  end

  def to_s; name; end
end

