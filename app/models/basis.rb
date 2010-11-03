class Basis < ActiveRecord::Base
  default_scope :order => 'bases.name ASC'

  named_scope :closed, lambda {
    { :conditions => [ 'closed_at < ?', DateTime.now.utc ] }
  }
  named_scope :open, lambda {
    { :conditions => [ 'open_at < ? AND closed_at > ?', DateTime.now.utc, DateTime.now.utc ] }
  }
  named_scope :upcoming, lambda {
    { :conditions => [ 'open_at > ?', DateTime.now.utc ] }
  }
  named_scope :no_draft_request_for, lambda { |organization|
    { :conditions => [
      'bases.id NOT IN (SELECT basis_id FROM requests ' +
      'WHERE requests.status IN (?) AND requests.organization_id = ? )',
      %w( started completed ), organization.id ] }
  }

  belongs_to :organization
  belongs_to :structure
  belongs_to :framework
  has_many :requests, :dependent => :destroy do
    def allocate_with_caps(status, club_sport, other)
      self.status_equals(status, :include => [ :organization, { :items => :editions } ] ).each do |r|
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
      Edition.perspective_equals(perspective).sum( 'amount', :conditions => [ "item_id IN (#{sub})", proxy_owner.id, status ] )
    end
    def item_amount_for_status(status)
      sub = "SELECT items.id FROM items INNER JOIN requests WHERE request_id = requests.id " +
            "AND basis_id = ? AND requests.status = ?"
      Item.sum('amount', :conditions => ["id IN (#{sub})", proxy_owner.id, status] )
    end
  end
  has_many :editions

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
    (open_at < DateTime.now) && (closed_at > DateTime.now)
  end

  def to_s; name; end
end

