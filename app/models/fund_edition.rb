class FundEdition < ActiveRecord::Base
  PERSPECTIVES = %w( requestor reviewer )

  attr_accessible :amount, :comment, :perspective,
    :administrative_expense_attributes, :local_event_expense_attributes,
    :speaker_expense_attributes, :travel_event_expense_attributes,
    :durable_good_expense_attributes, :publication_expense_attributes,
    :external_equity_report_attributes, :documents_attributes
  attr_readonly :fund_item_id, :perspective

  belongs_to :fund_item, :inverse_of => :fund_editions
  belongs_to :fund_request, :inverse_of => :fund_editions

  has_one :administrative_expense, :inverse_of => :fund_edition
  has_one :durable_good_expense, :inverse_of => :fund_edition
  has_one :external_equity_report, :inverse_of => :fund_edition
  has_one :local_event_expense, :inverse_of => :fund_edition
  has_one :publication_expense, :inverse_of => :fund_edition
  has_one :speaker_expense, :inverse_of => :fund_edition
  has_one :travel_event_expense, :inverse_of => :fund_edition

  has_many :documents, :inverse_of => :fund_edition do
    def for_type?( document_type )
      self.map { |d| d.document_type }.include?( document_type )
    end

    def populate
      return if proxy_owner.fund_item.blank? || proxy_owner.fund_item.node.blank?
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

  has_paper_trail :class_name => 'SecureVersion'

  scope :initial, where( :perspective => PERSPECTIVES.first )
  scope :final, where( :perspective => PERSPECTIVES.last )

  validates :fund_item, :presence => true
  validates :fund_request, :presence => true
  validates :amount,
    :numericality => { :greater_than_or_equal_to => 0 }
  validates :perspective, :inclusion => { :in => PERSPECTIVES },
    :uniqueness => { :scope => :fund_item_id }
  validate :amount_must_be_within_requestable_max,
    :amount_must_be_within_original_edition, :amount_must_be_within_node_limit
  validate :previous_edition_must_exist, :item_and_request_must_have_same_grant,
    :on => :create

  after_save :set_fund_item_title

  def nested_changed?
    return true if changed?
    return true if requestable && requestable.changed?
    documents.each { |document| return true if document.changed? }
    false
  end

  def title
    return requestable.title if requestable
    nil
  end

  def title?; !title.blank?; end

  def max_fund_request
    amounts = []
    amounts << fund_item.node.item_amount_limit if fund_item && fund_item.node
    amounts << requestable.max_fund_request if requestable
    unless previous_perspective.blank?
      amounts << fund_item.fund_editions.where( :perspective => FundEdition::PERSPECTIVES[FundEdition::PERSPECTIVES.index(perspective) - 1] ).first.amount
    end
    amounts.sort.first
  end

  def requestable(force_reload=false)
    return nil if fund_item.nil? || fund_item.node.nil? || fund_item.node.requestable_type.blank?
    self.send("#{fund_item.node.requestable_type.underscore}",force_reload)
  end

  def build_requestable(attributes={})
    return nil if fund_item.nil? || fund_item.node.nil? || fund_item.node.requestable_type.blank?
    self.send("build_#{fund_item.node.requestable_type.underscore}",attributes)
  end

  def create_requestable(attributes={})
    return nil if fund_item.nil? || fund_item.node.nil? || fund_item.node.requestable_type.blank?
    self.send("create_#{fund_item.node.requestable_type.underscore}",attributes)
  end

  def requestable=(requestable)
    return nil if fund_item.nil? || fund_item.node.nil? || fund_item.node.requestable_type.blank?
    self.send("#{fund_item.node.requestable_type.underscore}=",requestable)
  end

  # Returns the index in the PERSPECTIVES sequence for this edition
  def perspective_index
    return nil unless perspective
    PERSPECTIVES.index(perspective)
  end

  # Returns the perspective of previous edition in sequence
  # * returns nil if this is initial edition
  def previous_perspective
    return nil unless i = perspective_index && i && i > 0
    PERSPECTIVES[i - 1]
  end

  # Returns the perspective of next_perspective edition in sequence
  # * returns nil if this is final edition
  def next_perspective
    return nil unless i = perspective_index
    PERSPECTIVES[i + 1]
  end

  # Returns the next edition relative to this edition
  # * nil if this edition is last
  def next
    return nil unless next_perspective
    fund_item.fund_editions.next_to( self )
  end

  # Returns the previous edition relative to this edition
  # * nil if this edition is first
  def previous
    return nil unless previous_perspective
    fund_item.fund_editions.previous_to( self )
  end

  def to_s; "#{perspective} fund_edition of #{fund_item}"; end

  protected

  def item_and_request_must_have_same_grant
    return if fund_item.blank? || fund_request.blank?
    if fund_item.fund_grant != fund_request.fund_grant
      errors.add(:fund_item, " is not part of the fund grant for the request.")
    end
  end

  def amount_must_be_within_node_limit
    return if amount.blank? || fund_item.blank? || fund_item.node.blank?
    if amount > fund_item.node.item_amount_limit
      errors.add(:amount, " is greater than maximum for #{fund_item.node}.")
    end
  end

  def amount_must_be_within_requestable_max
    return if requestable.nil? || amount.nil?
    if amount > requestable.max_fund_request then
      errors.add(:amount, " is greater than the maximum fund_request.")
    end
  end

  def amount_must_be_within_original_edition
    return unless amount && previous
    if amount > previous.amount
      errors.add(:amount, " is greater than original fund_request amount.")
    end
  end

  # Should not create an fund_edition if there is no previous fund_edition for the fund_item
  # * on create only
  # * only if the perspective is not first or there is no fund_item
  def previous_edition_must_exist
    return unless previous_perspective && fund_item
    if previous.blank?
      errors.add( :perspective, " is not allowed until there is a " +
        "#{previous_perspective} fund_edition for the fund_item" )
    end
  end

  # Use an instance variable to prevent infinite recursion
  def set_fund_item_title
    return if @set_fund_item_title
    if title? && ( perspective == PERSPECTIVES.first )
      fund_item.title = title if title? && fund_item.title != title
      @set_fund_item_title = true
      fund_item.save
      @set_fund_item_title = false
    end
  end

end
