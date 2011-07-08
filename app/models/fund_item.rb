class FundItem < ActiveRecord::Base
  #TODO conditionally make amount available based on user role
  attr_accessible :node_id, :parent_id, :new_position, :amount,
    :fund_editions_attributes
  attr_readonly :fund_request_id, :node_id, :parent_id

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
      for_request( edition.request ).
      select { |e| e.perspective == edition.previous_perspective }.first
    end

    # Next edition relative to a specified edition
    def next_to( edition )
      for_request( edition.request ).
      select { |e| e.perspective == edition.next_perspective }.first
    end

    # This was formerly next( attributes = {} )
    # Build the next edition of the item for specified request
    # * nil if last edition already built or last edition of request is not
    #   yet saved
    # * optionally applies attributes by mass assignment
    def build_next_for_fund_request(request, attributes = {})
      next_edition = for_request( request ).last.next
      return nil if next_edition.blank?
      next_edition.attributes = attributes
      next_edition
    end
  end
  has_many :documents, :through => :fund_editions
  has_many :document_types, :through => :node

  scope :root, where( :parent_id => nil )

  has_paper_trail :class_name => 'SecureVersion'

  acts_as_list :scope => :parent_id
  acts_as_tree

  accepts_nested_attributes_for :fund_editions

  validates :title, :presence => true
  validates :node, :presence => true
  validates :fund_grant, :presence => true
  validates :amount,
    :numericality => { :greater_than_or_equal_to => 0.0 }
  validate :node_must_be_allowed, :on => :create

  before_validation :set_title

  attr_accessor :new_position

  def allowed_nodes
    Node.allowed_for_children_of( fund_grant, parent ).where( :structure_id => fund_grant.fund_source.structure_id )
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

