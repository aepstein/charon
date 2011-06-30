class Node < ActiveRecord::Base
  ALLOWED_TYPES = {
    'External Equity' => 'ExternalEquityReport',
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
  has_many :items, :inverse_of => :node
  acts_as_tree

  validates :name, :presence => true,
    :uniqueness => { :scope => [ :structure_id ] }
  validates :structure, :presence => true
  validates :requestable_type,
    :inclusion => { :in => Node::ALLOWED_TYPES.values, :allow_blank => true }
  validates :category, :presence => true

  default_scope :order => 'nodes.name ASC'

  scope :allowed_for_children_of, lambda { |request, parent_item|
    parent_node_sql = parent_item.nil? ? "IS NULL" : "= #{parent_item.node_id}"
    parent_item_sql = parent_item.nil? ? "IS NULL" : "= #{parent_item.id}"
    parent_item_count_sql =
      "(SELECT COUNT(*) FROM items WHERE items.request_id = #{request.id} AND " +
      "items.node_id = nodes.id AND items.parent_id #{parent_item_sql})"
    where( "nodes.parent_id #{parent_node_sql} AND " +
           "nodes.item_quantity_limit > #{parent_item_count_sql}" )
  }

  def to_s; name; end

end

