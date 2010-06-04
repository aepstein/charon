class Edition < ActiveRecord::Base
  PERSPECTIVES = %w( requestor reviewer )
  belongs_to :item, :touch => true
  has_one :administrative_expense
  has_one :local_event_expense
  has_one :speaker_expense
  has_one :travel_event_expense
  has_one :durable_good_expense
  has_one :publication_expense
  has_one :external_equity_report
  has_many :documents do
    def for_type?( document_type )
      self.map { |d| d.document_type }.include?( document_type )
    end
    def populate
      return if proxy_owner.item.nil? || proxy_owner.item.node.nil?
      proxy_owner.node.document_types.each do |document_type|
        self.build(:document_type => document_type) if self.select { |d| d.document_type == document_type }.empty?
      end
    end
  end
  accepts_nested_attributes_for :administrative_expense
  accepts_nested_attributes_for :local_event_expense
  accepts_nested_attributes_for :speaker_expense
  accepts_nested_attributes_for :travel_event_expense
  accepts_nested_attributes_for :durable_good_expense
  accepts_nested_attributes_for :publication_expense
  accepts_nested_attributes_for :external_equity_report
  accepts_nested_attributes_for :documents, :reject_if => proc { |attributes| attributes['attached'].nil? || attributes['attached'].original_filename.blank? }

  validates_presence_of :item
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  validates_inclusion_of :perspective, :in => PERSPECTIVES
  validates_uniqueness_of :perspective, :scope => :item_id
  validate :amount_must_be_within_requestable_max, :amount_must_be_within_original_edition, :amount_must_be_within_node_limit

  delegate :request, :to => :item
  delegate :node, :to => :item
  delegate :document_types, :to => :node
  delegate :requestors, :to => :request

  before_validation_on_create :initialize_documents
  before_validation_on_create :initialize_requestable
  after_save :set_item_title

  def set_item_title
    if title.nil?
      item.touch
      item.request.touch
    else
      item.title = title
      item.save
    end
  end

  def title
    return nil unless requestable
    requestable.title
  end

  def initialize_documents
    documents.each { |document| document.edition = self }
  end

  def initialize_requestable
    requestable.edition = self if requestable
  end

  def max_request
    amounts = []
    amounts << item.node.item_amount_limit if item && item.node
    amounts << requestable.max_request if requestable
    unless perspective.blank? || perspective == Edition::PERSPECTIVES.first
      amounts << item.editions.perspective_equals( Edition::PERSPECTIVES[Edition::PERSPECTIVES.index(perspective) - 1] ).first.amount
    end
    amounts.sort.first
  end

  def amount_must_be_within_node_limit
    return if item.nil? || amount.nil?
    if amount > item.node.item_amount_limit
      errors.add(:amount, " is greater than maximum for #{node}.")
    end
  end

  def amount_must_be_within_requestable_max
    return if requestable.nil? || amount.nil?
    if amount > requestable.max_request then
      errors.add(:amount, " is greater than the maximum request.")
    end
  end

  def amount_must_be_within_original_edition
    return unless amount && previous
    if amount > previous.amount
      errors.add(:amount, " is greater than original request amount.")
    end
  end

  def requestable(force_reload=false)
    return nil if item.nil? || item.node.nil? || item.node.requestable_type.blank?
    self.send("#{item.node.requestable_type.underscore}",force_reload)
  end

  def build_requestable(attributes={})
    return nil if item.nil? || item.node.nil? || item.node.requestable_type.blank?
    self.send("build_#{item.node.requestable_type.underscore}",attributes)
  end

  def create_requestable(attributes={})
    return nil if item.nil? || item.node.nil? || item.node.requestable_type.blank?
    self.send("create_#{item.node.requestable_type.underscore}",attributes)
  end

  def requestable=(requestable)
    return nil if item.nil? || item.node.nil? || item.node.requestable_type.blank?
    self.send("#{item.node.requestable_type.underscore}=",requestable)
  end

  def may_create?(user)
    return request.may_revise?(user) if perspective == 'reviewer'
    request.may_update?(user) if perspective == 'requestor'
  end

  def may_update?(user)
    return request.may_revise?(user) if perspective == 'reviewer'
    request.may_update?(user)
  end

  def may_destroy?(user)
    may_update? user
  end

  def may_see?(user)
    if perspective == 'reviewer'
      return request.may_revise?(user) || request.may_review?(user)
    end
    request.may_see?(user)
  end

  def previous
    return nil unless perspective && Edition::PERSPECTIVES.index(perspective) && Edition::PERSPECTIVES.index(perspective) > 0
    item.editions.perspective_equals( Edition::PERSPECTIVES[Edition::PERSPECTIVES.index(perspective) - 1] ).first
  end

  def to_s; "#{perspective} edition of #{item}"; end
end

