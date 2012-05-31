class FundItem < ActiveRecord::Base
  attr_accessible :node_id, :parent_id, :amount, :fund_editions_attributes,
    :fund_allocations_attributes
  attr_readonly :fund_request_id, :node_id, :ancestry, :parent_id

  belongs_to :node, inverse_of: :fund_items
  belongs_to :fund_grant, touch: true, inverse_of: :fund_items
  has_many :fund_allocations, inverse_of: :fund_item, dependent: :destroy do
    def find_or_build_for_fund_request( fund_request )
      fund_allocation = for_request( fund_request )
      return fund_allocation unless fund_allocation.blank?
      build_for_fund_request fund_request
    end
    def build_for_fund_request( fund_request )
      fund_allocation = build
      fund_allocation.fund_request = fund_request
      fund_allocation
    end
    def for_request(  fund_request )
      select { |a| a.fund_request == fund_request }
    end
  end
  has_many :fund_editions, inverse_of: :fund_item, dependent: :destroy do

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
      return if proxy_association.owner.node.blank?
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
      next_edition.build_requestable if proxy_association.owner.node.requestable_type?
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
  has_many :fund_requests, through: :fund_editions
  has_many :documents, through: :fund_editions
  has_many :document_types, through: :node

  has_paper_trail class_name: 'SecureVersion'
  has_ancestry orphan_strategy: :destroy

  accepts_nested_attributes_for :fund_editions
  accepts_nested_attributes_for :fund_allocations,
    reject_if: proc { |a| a['amount'].blank? }

  scope :ordered, order { position }

  # Appended items
  # * must not be amended
  scope :appended_to, lambda { |fund_request|
    where { |i| i.id.not_in( FundItem.select { id }.amended_in( fund_request ) ) }
  }

  # Amended items
  # * must have an edition in another actionable request that is older than this
  scope :amended_in, lambda { |fund_request|
    where do |i|
      # Must have an edition
      i.id.in( FundEdition.select { fund_item_id }.
        where do |e|
          # ...which is in request that is
          e.fund_request_id.in(
            FundRequest.select { id }.
            # another request
            where { |r| r.id.not_eq( fund_request.id ) }.
            # not an unactionable state
            without_state( FundRequest::UNACTIONABLE_STATES ).
            # older than this request
            where { |r| r.created_at.lt( fund_request.created_at ) }
          )
        end
      )
    end
  }
  scope :documentable, joins { document_types.inner }

  validates :title, presence: true
  validates :node, presence: true
  validates :fund_grant, presence: true
  validate :node_must_be_allowed, :parent_must_be_in_same_fund_grant,
    on: :create

  before_validation :set_title
  before_validation :initialize_nested_position, on: :create
  before_create :clear_for_new_position

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
    return true if position

    last_position = if is_root?
      fund_grant.fund_items.maximum( :position )
    else
      siblings.maximum( :position ) || parent.position
    end

    self.position = ( last_position.blank? ? 1 : ( last_position + 1 ) )
  end

  # Clear space for item
  # * if the item occurs before the end of an existing list, move the existing
  # items of same or later position down a space to make room for the item
  def clear_for_new_position
    end_of_list = fund_grant.fund_items.maximum( :position )
    unless end_of_list && end_of_list < position
      fund_grant.fund_items.where { |i| i.id != id }.
        where { |i| i.position >= position }.update_all(
          'fund_items.position = fund_items.position + 1' )
    end
    true
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

  def parent_must_be_in_same_fund_grant
    return unless parent && fund_grant
    if parent.fund_grant != fund_grant
      errors.add( :parent, "must be part of the same fund grant" )
    end
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

