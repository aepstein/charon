class FundQueue < ActiveRecord::Base
  attr_accessible :advertised_submit_at, :submit_at, :release_at,
    :fund_request_type_ids
  attr_readonly :fund_source_id

  belongs_to :fund_source, :inverse_of => :fund_queues

  has_many :fund_requests, :inverse_of => :fund_queue, :dependent => :nullify

  has_and_belongs_to_many :fund_request_types

  default_scope order( 'fund_queues.submit_at ASC' )
  scope :past, lambda { where( :submit_at.lt => Time.zone.now ) }
  scope :future, lambda { where( :submit_at.gt => Time.zone.now ) }

  validates :fund_source, :presence => true
  validates :submit_at, :presence => true,
    :uniqueness => { :scope => :fund_source_id },
    :timeliness => { :type => :datetime, :before => :release_at,
      :after => :open_at }
  validates :advertised_submit_at, :presence => true,
    :timeliness => { :type => :datetime, :on_or_before => :submit_at }

  before_validation do |queue|
    queue.advertised_submit_at = queue.submit_at if queue.advertised_submit_at.blank?
  end

  def open_at; fund_source.open_at if fund_source; end

  def to_s
    return super unless advertised_submit_at? || submit_at?
    if Time.zone.now < advertised_submit_at
      "#{advertised_submit_at.to_s(:rfc822)}"
    else
      "#{submit_at.to_s(:rfc822)} (extended from #{advertised_submit_at(:rfc822)})"
    end
  end

end

