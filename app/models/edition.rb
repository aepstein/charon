class Edition < ActiveRecord::Base
  PERSPECTIVES = %w( requestor reviewer )
  UPDATABLE_ATTRIBUTES = [ :amount, :comment, :perspective,
    :administrative_expense_attributes, :local_event_expense_attributes,
    :speaker_expense_attributes, :travel_event_expense_attributes,
    :durable_good_expense_attributes, :publication_expense_attributes,
    :external_equity_report_attributes, :documents_attributes ]

  attr_readonly :item_id, :perspective

  belongs_to :item, :inverse_of => :editions
  has_one :administrative_expense, :inverse_of => :edition
  has_one :local_event_expense, :inverse_of => :edition
  has_one :speaker_expense, :inverse_of => :edition
  has_one :travel_event_expense, :inverse_of => :edition
  has_one :durable_good_expense, :inverse_of => :edition
  has_one :publication_expense, :inverse_of => :edition
  has_one :external_equity_report, :inverse_of => :edition
  has_many :documents, :inverse_of => :edition do
    def for_type?( document_type )
      self.map { |d| d.document_type }.include?( document_type )
    end

    def populate
      return if proxy_owner.item.blank? || proxy_owner.item.node.blank?
      proxy_owner.node.document_types.each do |type|
        build_for_type( type ) unless self.map(&:document_type).include? type
      end
    end

    protected

    def build_for_type( type )
      document = build
      document.document_type = type
      document
    end
  end
  accepts_nested_attributes_for :administrative_expense
  accepts_nested_attributes_for :local_event_expense
  accepts_nested_attributes_for :speaker_expense
  accepts_nested_attributes_for :travel_event_expense
  accepts_nested_attributes_for :durable_good_expense
  accepts_nested_attributes_for :publication_expense
  accepts_nested_attributes_for :external_equity_report
  accepts_nested_attributes_for :documents, :reject_if => proc { |attributes| attributes['original'].blank? || attributes['original'].original_filename.blank? }

  validates_presence_of :item
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  validates_inclusion_of :perspective, :in => PERSPECTIVES
  validates_uniqueness_of :perspective, :scope => :item_id
  validate :amount_must_be_within_requestable_max,
    :amount_must_be_within_original_edition, :amount_must_be_within_node_limit
  validate :previous_edition_must_exist, :on => :create

  delegate :request, :to => :item
  delegate :node, :to => :item
  delegate :document_types, :to => :node
  delegate :requestors, :to => :request

  after_save :set_item_title

  def title
    return requestable.title if requestable
    nil
  end

  def title?; !title.blank?; end

  def max_request
    amounts = []
    amounts << item.node.item_amount_limit if item && item.node
    amounts << requestable.max_request if requestable
    unless perspective.blank? || perspective == Edition::PERSPECTIVES.first
      amounts << item.editions.where( :perspective => Edition::PERSPECTIVES[Edition::PERSPECTIVES.index(perspective) - 1] ).first.amount
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

  # Should not create an edition if there is no previous edition for the item
  # * on create only
  # * only if the perspective is not first or there is no item
  def previous_edition_must_exist
    return if previous_perspective.blank? || item.blank?
    if previous.blank?
      errors.add( :perspective, " is not allowed until there is a " +
        "#{previous_perspective} edition for the item" )
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

  def previous_perspective
    return nil unless perspective && perspective != PERSPECTIVES.first &&
      PERSPECTIVES.include?( perspective )
    PERSPECTIVES[PERSPECTIVES.index(perspective) - 1]
  end

  def previous
    return nil unless previous_perspective
    item.editions.where( :perspective => previous_perspective ).first
  end

  def to_s; "#{perspective} edition of #{item}"; end

  private

  # Use an instance variable to prevent infinite recursion
  def set_item_title
    return if @set_item_title
    if title? && ( perspective == PERSPECTIVES.first )
      item.title = title if title? && item.title != title
      @set_item_title = true
      item.save
      @set_item_title = false
    end
  end

end

