class Basis < ActiveRecord::Base
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
      "requests.status = 'started' AND organizations_requests.organization_id = ? )",
      organization.id ] }
  }

  belongs_to :organization
  belongs_to :structure
  belongs_to :framework
  has_many :requests do
    def build_for( organization )
      r = self.build
      r.organizations << organization
      r
    end
  end

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :organization
  validates_presence_of :framework
  validates_presence_of :structure
  validates_presence_of :organization
  validates_datetime :open_at
  validates_datetime :closed_at, :after => :open_at

  def open?
    (open_at < DateTime.now) && (closed_at > DateTime.now)
  end

  def eligible_to_request?(organization)
    framework.organization_eligible?(organization)
  end
end

