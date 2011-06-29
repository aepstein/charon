class Basis < ActiveRecord::Base
  attr_accessible :name, :framework_id, :structure_id, :contact_name,
    :contact_email, :open_at, :closed_at, :release_message, :contact_web,
    :submissions_due_at
  attr_readonly :framework_id, :structure_id

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

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :organization
  validates_presence_of :framework
  validates_presence_of :structure
  validates_presence_of :organization
  validates_presence_of :contact_name
  validates_format_of :contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :contact_web
  validates_datetime :open_at
  validates_datetime :closed_at, :after => :open_at
  validates_datetime :submissions_due_at, :before => :closed_at

  def open?
    (open_at < Time.zone.now) && (closed_at > Time.zone.now)
  end

  def to_s; name; end
end

