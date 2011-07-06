class FundEdition < ActiveRecord::Base
  PERSPECTIVES = %w( fund_requestor reviewer )

  attr_accessible :amount, :comment, :perspective,
    :administrative_expense_attributes, :local_event_expense_attributes,
    :speaker_expense_attributes, :travel_event_expense_attributes,
    :durable_good_expense_attributes, :publication_expense_attributes,
    :external_equity_report_attributes, :documents_attributes
  attr_readonly :fund_item_id, :perspective

  belongs_to :fund_item, :inverse_of => :fund_editions
  has_one :administrative_expense, :inverse_of => :fund_edition
  has_one :local_event_expense, :inverse_of => :fund_edition
  has_one :speaker_expense, :inverse_of => :fund_edition
  has_one :travel_event_expense, :inverse_of => :fund_edition
  has_one :durable_good_expense, :inverse_of => :fund_edition
  has_one :publication_expense, :inverse_of => :fund_edition
  has_one :external_equity_report, :inverse_of => :fund_edition
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

  validates :fund_item, :presence => true
  validates :amount,
    :numericality => { :greater_than_or_equal_to => 0 }
  validates :perspective, :inclusion => { :in => PERSPECTIVES },
    :uniqueness => { :scope => :fund_item_id }
  validate :amount_must_be_within_fund_requestable_max,
    :amount_must_be_within_original_fund_edition, :amount_must_be_within_node_limit
  validate :previous_fund_edition_must_exist, :on => :create

  delegate :fund_request, :to => :fund_item
  delegate :node, :to => :fund_item
  delegate :document_types, :to => :node
  delegate :fund_requestors, :to => :fund_request

  after_save :set_fund_item_title

  def nested_changed?
    return true if changed?
    return true if fund_requestable && fund_requestable.changed?
    documents.each { |document| return true if document.changed? }
    false
  end

  def title
    return fund_requestable.title if fund_requestable
    nil
  end

  def title?; !title.blank?; end

  def max_fund_request
    amounts = []
    amounts << fund_item.node.fund_item_amount_limit if fund_item && fund_item.node
    amounts << fund_requestable.max_fund_request if fund_requestable
    unless perspective.blank? || perspective == FundEdition::PERSPECTIVES.first
      amounts << fund_item.fund_editions.where( :perspective => FundEdition::PERSPECTIVES[FundEdition::PERSPECTIVES.index(perspective) - 1] ).first.amount
    end
    amounts.sort.first
  end

  def fund_requestable(force_reload=false)
    return nil if fund_item.nil? || fund_item.node.nil? || fund_item.node.fund_requestable_type.blank?
    self.send("#{fund_item.node.fund_requestable_type.underscore}",force_reload)
  end

  def build_fund_requestable(attributes={})
    return nil if fund_item.nil? || fund_item.node.nil? || fund_item.node.fund_requestable_type.blank?
    self.send("build_#{fund_item.node.fund_requestable_type.underscore}",attributes)
  end

  def create_fund_requestable(attributes={})
    return nil if fund_item.nil? || fund_item.node.nil? || fund_item.node.fund_requestable_type.blank?
    self.send("create_#{fund_item.node.fund_requestable_type.underscore}",attributes)
  end

  def fund_requestable=(fund_requestable)
    return nil if fund_item.nil? || fund_item.node.nil? || fund_item.node.fund_requestable_type.blank?
    self.send("#{fund_item.node.fund_requestable_type.underscore}=",fund_requestable)
  end

  def previous_perspective
    return nil unless perspective && perspective != PERSPECTIVES.first &&
      PERSPECTIVES.include?( perspective )
    PERSPECTIVES[PERSPECTIVES.index(perspective) - 1]
  end

  def previous
    return nil unless previous_perspective
    fund_item.fund_editions.where( :perspective => previous_perspective ).first
  end

  def to_s; "#{perspective} fund_edition of #{fund_item}"; end

  private

  def amount_must_be_within_node_limit
    return if fund_item.nil? || amount.nil?
    if amount > fund_item.node.fund_item_amount_limit
      errors.add(:amount, " is greater than maximum for #{node}.")
    end
  end

  def amount_must_be_within_fund_requestable_max
    return if fund_requestable.nil? || amount.nil?
    if amount > fund_requestable.max_fund_request then
      errors.add(:amount, " is greater than the maximum fund_request.")
    end
  end

  def amount_must_be_within_original_fund_edition
    return unless amount && previous
    if amount > previous.amount
      errors.add(:amount, " is greater than original fund_request amount.")
    end
  end

  # Should not create an fund_edition if there is no previous fund_edition for the fund_item
  # * on create only
  # * only if the perspective is not first or there is no fund_item
  def previous_fund_edition_must_exist
    return if previous_perspective.blank? || fund_item.blank?
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

