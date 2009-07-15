class Basis < ActiveRecord::Base
  named_scope :closed, lambda {
    { :conditions => [ 'closed_at < ?', DateTime.now ] }
  }
  named_scope :open, lambda {
    { :conditions => [ 'open_at < ? AND closed_at > ?', DateTime.now, DateTime.now ] }
  }
  named_scope :upcoming, lambda {
    { :conditions => [ 'open_at > ?', DateTime.now ] }
  }
  named_scope :no_draft_request_for, lambda { |organization|
    { :include => [ :structure ],
      :conditions => [
      'bases.id NOT IN (SELECT basis_id FROM requests, organizations_requests ' +
      'WHERE requests.id=organizations_requests.request_id AND ' +
      "requests.status = 'draft' AND organizations_requests.organization_id = ? )",
      organization.id ] }
  }
  belongs_to :structure
  has_many :requests do
    def build_for( organization )
      r = self.build
      r.organizations << organization
      r
    end
  end

  delegate :eligible_to_request?, :to => :structure

  validates_presence_of :structure
  validates_datetime :closed_at, :after => :open_at

  def name
    "#{structure.name} beginning at #{open_at.to_s}"
  end

  def open?
    (open_at < DateTime.now) && (closed_at > DateTime.now)
  end
end

