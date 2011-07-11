class FundQueue < ActiveRecord::Base
  belongs_to :fund_source, :inverse_of => :fund_queues

  has_many :fund_requests, :inverse_of => :fund_queue, :dependent => :nullify

  default_scope order( 'fund_queues.submit_at ASC' )
  scope :past, lambda { where( :submit_at.lt => Time.zone.now ) }
  scope :future, lambda { where( :submit_at.gt => Time.zone.now ) }

  validates :fund_source, :presence => true
  validates :submit_at, :presence => true,
    :uniqueness => { :scope => :fund_source_id },
    :timeliness => { :type => :datetime, :before => :release_at,
      :after => :open_at }

  def open_at; fund_source.open_at if fund_source; end

end

