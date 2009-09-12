class Basis < ActiveRecord::Base
  include GlobalModelAuthorization

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
    { :include => [ :structure ],
      :conditions => [
      'bases.id NOT IN (SELECT basis_id FROM requests, organizations_requests ' +
      'WHERE requests.id=organizations_requests.request_id AND ' +
      "requests.status IN (?) AND organizations_requests.organization_id = ? )",
      %w( started completed ), organization.id ] }
  }

  belongs_to :organization
  belongs_to :structure
  belongs_to :framework
  has_many :requests, :dependent => :destroy do
    def build_for( organization )
      r = self.build
      r.organizations << organization
      r
    end
    def amount_for_perspective_and_status(perspective, status)
      sub = "SELECT items.id FROM items INNER JOIN requests WHERE request_id = requests.id " +
            "AND basis_id = ? AND requests.status = ?"
      Version.perspective_equals(perspective).sum( 'amount', :conditions => [ "item_id IN (#{sub})", proxy_owner.id, status ] )
    end
  end
  has_many :versions

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :organization
  validates_presence_of :framework
  validates_presence_of :structure
  validates_presence_of :organization
  validates_presence_of :contact_name
  validates_format_of :contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_datetime :open_at
  validates_datetime :closed_at, :after => :open_at

  def open?
    (open_at < DateTime.now) && (closed_at > DateTime.now)
  end

  def eligible_to_request?(organization)
    framework.organization_eligible?(organization)
  end

  def to_s
    name
  end
end

