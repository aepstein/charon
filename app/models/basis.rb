class Basis < ActiveRecord::Base
  KINDS = %w( safc gpsafc )

  named_scope :closed, lambda {
    { :conditions => [ 'closed_at < ?', DateTime.now ] }
  }
  named_scope :open, lambda {
    { :conditions => [ 'open_at < ? AND closed_at > ?', DateTime.now, DateTime.now ] }
  }
  named_scope :upcoming, lambda {
    { :conditions => [ 'open_at > ?', DateTime.now ] }
  }

  belongs_to :structure
  has_many :requests

  validates_presence_of :structure
  validates_inclusion_of :kind, :in => KINDS

  def name
    "#{structure.name} beginning at #{open_at.to_s}"
  end
end

