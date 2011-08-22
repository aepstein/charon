class FundItem < ActiveRecord::Base
  #TODO conditionally make amount available based on user role
  attr_accessible :node_id, :parent_id, :amount, :fund_editions_attributes
  attr_readonly :fund_request_id, :node_id, :ancestry

  belongs_to :node, :inverse_of => :fund_items
  belongs_to :fund_grant, :touch => true, :inverse_of => :fund_items
  has_many :fund_editions, :inverse_of => :fund_item do

    # Editions associated with a specific request
    # * sorts by perspective sequence
    def for_request( request )
      select { |edition| edition.fund_request == request &&
        edition.perspective }.
      sort { |x, y| FundEdition::PERSPECTIVES.index(x.perspective) <=>
        FundEdition::PERSPECTIVES.index(y.perspective) }
    end

    # Previous edition relative to a specified edition
    def previous_to( edition )
      for_request( edition.fund_request ).
      select { |e| e.perspective == edition.previous_perspective }.first
    end

    # Next edition relative to a specified edition
    def next_to( edition )
      for_request( edition.fund_request ).
      select { |e| e.perspective == edition.next_perspective }.first
    end

    # Builds the next edition of the item for the request
    # * skips build if an existing new record exists or if the last perspective
    #   is present
    def populate_for_fund_request( request )
      return if @association.owner.node.blank?
      last = for_request( request ).last
      if last.blank? || ( last.persisted? && last.perspective != FundEdition::PERSPECTIVES.last )
        next_edition = build_next_for_fund_request( request )
      end
    end

    # Build the next edition of the item for specified request
    # * optionally applies attributes by mass assignment
    # * raises exceptions if last edition is new record or final perspective
    def build_next_for_fund_request(request, attributes = {})
      last_edition = for_request( request ).last
      if last_edition.blank?
        next_perspective = FundEdition::PERSPECTIVES.first
      elsif last_edition.new_record?
        raise ActiveRecord::ActiveRecordError, 'Last edition is new.'
      elsif last_edition.next_perspective.blank?
        raise ActiveRecord::ActiveRecordError, 'Last edition has final perspective.'
      else
        next_perspective = last_edition.next_perspective
      end

      next_edition = build( attributes )
      next_edition.build_requestable if @association.owner.node.requestable_type?
      if last_edition
        next_edition.attributes = last_edition.attributes
        if last_edition.requestable
          next_edition.requestable.attributes = last_edition.requestable.attributes
        end
      end
      next_edition.perspective = next_perspective
      next_edition.fund_request = request

      next_edition
    end
  end
  has_many :fund_requests, :through => :fund_editions
  has_many :documents, :through => :fund_editions
  has_many :document_types, :through => :node

  has_paper_trail :class_name => 'SecureVersion'
  has_ancestry

  acts_as_list :scope => [ :fund_grant_id ]

  accepts_nested_attributes_for :fund_editions

  scope :ordered, order { position }
  scope :appended_to, lambda { |fund_request|
    where { id.not_in( FundEdition.unscoped.joins { fund_request }.
      select { fund_item_id }.merge( FundRequest.unscoped.actionable ) ) }
  }
  scope :documentable, joins { document_types.inner }

  validates :title, :presence => true
  validates :node, :presence => true
  validates :fund_grant, :presence => true
  validates :amount,
    :numericality => { :greater_than_or_equal_to => 0.0 }
  validate :node_must_be_allowed, :on => :create

  before_validation :set_title
  before_validation :initialize_nested_position, :on => :create

  # What types of nodes can this item be created as?
  def allowed_nodes
    if is_root?
      Node.with_root_fund_items_for( fund_grant ).under_limit
    else
      Node.with_child_fund_items_for( parent ).under_limit
    end
  end

  def to_s; title; end

  # Has the item been appended to the fund_request?
  # * it is appended if the item is new or if the item is not associated with
  #   any other actionable request (e.g. is not in process or released)
  def appended_to_fund_request?( fund_request )
    return true if new_record? || fund_requests.actionable.empty?
    false
  end

  # Will inclusion of the item in a fund request exceed the appendable_quantity_limit
  # for that request?
  def exceeds_appendable_quantity_limit_for_fund_request?( fund_request )
    return false unless fund_request.fund_request_type.appendable_quantity_limit
    return true if ( fund_request.fund_items.appended.where { id != my { id } }.length ==
       fund_request.fund_request_type.appendable_quantity_limit )
    false
  end

  protected

  # Set the initial position to which the item should be assigned
  def initialize_nested_position
    return true if position || is_root?
    last = siblings.ordered.last || parent
    self.position = last.position + 1
  end

  # Set the title automatically
  # * TODO: flexible_budgets: should use requestor title in latest requestor edition
  # * edition-supplied title from first edition, if available
  # * node name if nothing else is available
  def set_title
    if fund_editions.first && fund_editions.first.title?
      self.title ||= fund_editions.first.title
    elsif node
      self.title ||= node.name
    end
  end

  def node_must_be_allowed
    return if node.blank? || fund_grant.blank?
    errors.add( :node_id, "must be an allowed node." ) unless allowed_nodes.include?( node )
  end

  def must_not_exceed_appendable_quantity_limit
    fund_request = fund_editions.map(&:fund_request).select(&:actionable?).first
    return unless fund_request
    if exceeds_appendable_quantity_limit_for_fund_request( fund_request )
      errors.add :base,
        "exceeds number of allowed items for #{fund_request.fund_request_type}"
    end
  end

end

