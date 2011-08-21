class Node < ActiveRecord::Base
  ALLOWED_TYPES = {
    'Administrative' => 'AdministrativeExpense',
    'Durable Good' => 'DurableGoodExpense',
    'Local Event' => 'LocalEventExpense',
    'Publication' => 'PublicationExpense',
    'Travel Event' => 'TravelEventExpense',
    'Speaker' => 'SpeakerExpense'
  }

  attr_accessible :name, :requestable_type, :item_amount_limit,
    :item_quantity_limit, :parent_id, :category_id
  attr_readonly :structure_id

  belongs_to :structure, :inverse_of => :nodes
  belongs_to :category, :inverse_of => :nodes
  has_and_belongs_to_many :document_types
  has_many :fund_items, :inverse_of => :node

  has_ancestry

  validates :name, :presence => true,
    :uniqueness => { :scope => [ :structure_id ] }
  validates :structure, :presence => true
  validates :requestable_type,
    :inclusion => { :in => Node::ALLOWED_TYPES.values, :allow_blank => true }
  validates :category, :presence => true
  validates :item_quantity_limit, :presence => true,
    :numericality => { :integer_only => true }

  default_scope :order => 'nodes.name ASC'

  # Outer joins to fund_items that are children of the fund_item
  # * limits to nodes that can be child fund_items of the fund_item
  scope :with_child_fund_items_for, lambda { |fund_item|
    fund_item.node.children.joins { fund_items.outer }.
    joins( "AND fund_items.ancestry = " +
      "#{connection.quote fund_item.child_ancestry}" )
  }
  # Outer joins to fund_items that are root items of the fund_grant
  # * limits to nodes that can be root fund_items of the fund_grant
  scope :with_root_fund_items_for, lambda { |fund_grant|
    fund_grant.fund_source.structure.nodes.roots.joins { fund_items.outer }.
    joins( "AND fund_items.ancestry IS NULL AND fund_items.fund_grant_id = " +
      "#{fund_grant.id}" )
  }
  # Returns only nodes with number of fund_items reaching limit for the node
  scope :at_limit, having { item_quantity_limit.eq( count( fund_items.id ) ) }.
    group { id }
  # Returns only nodes with number of fund_items less than the limit for the node
  scope :under_limit, having { item_quantity_limit.gt( count( fund_items.id ) ) }.
    group { id }

  def to_s; name; end

end

