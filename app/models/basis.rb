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
  belongs_to :structure
  has_many :requests


  validates_presence_of :structure
  validates_datetime :closed_at, :after => :open_at

  def name
    "#{structure.name} beginning at #{open_at.to_s}"
  end

  def open?
    (open_at < DateTime.now) && (closed_at > DateTime.now)
  end
end

