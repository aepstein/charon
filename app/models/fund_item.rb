class FundItem < ActiveRecord::Base
  #TODO conditionally make amount available based on user role
  attr_accessible :node_id, :parent_id, :new_position, :amount,
    :fund_editions_attributes
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

    # This was formerly next( attributes = {} )
    # Build the next edition of the item for specified request
    # * optionally applies attributes by mass assignment
    # * raises exceptions if last edition is new record or final perspective
    def build_next_for_fund_request(request, attributes = {})
      last_edition = for_request( request ).last
      if last_edition.blank?
        next_edition = build( attributes )
        next_edition.fund_request = request
        next_edition.perspective = FundEdition::PERSPECTIVES.first
        return next_edition
      end
      if last_edition.new_record?
        raise ActiveRecord::ActiveRecordError,
          'Last position is a new record.'
      end
      if last_edition.next_perspective.nil?
        raise ActiveRecord::ActiveRecordError,
          'Last position has final perspective.'
      end
      next_edition = build
      unless last_edition.requestable.blank?
        next_edition.requestable_attributes = last_edition.requestable_attributes
      end
      next_edition.attributes = last_edition.attributes.merge( attributes )
      next_edition.perspective = last_edition.next_perspective
      next_edition.fund_request = request
      next_edition
    end
  end
  has_many :documents, :through => :fund_editions
  has_many :document_types, :through => :node

  has_paper_trail :class_name => 'SecureVersion'
  has_ancestry

  acts_as_list :scope => [ :ancestry ]

  accepts_nested_attributes_for :fund_editions

  validates :title, :presence => true
  validates :node, :presence => true
  validates :fund_grant, :presence => true
  validates :amount,
    :numericality => { :greater_than_or_equal_to => 0.0 }
  validate :node_must_be_allowed, :on => :create

  before_validation :set_title

  attr_accessor :new_position

  # What types of nodes can this item be created as?
  def allowed_nodes
    if is_root?
      Node.with_root_fund_items_for( fund_grant ).under_limit
    else
      Node.with_child_fund_items_for( parent ).under_limit
    end
  end

  def node_must_be_allowed
    return if node.nil?
    errors.add( :node_id, "must be an allowed node." ) unless allowed_nodes.include?( node )
  end

  def to_s; title; end

  protected

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

end

