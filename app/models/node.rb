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

  default_scope :order => 'nodes.name ASC'

  named_scope :allowed_for_children_of, lambda { |request, parent_item|
    parent_node_sql = parent_item.nil? ? "IS NULL" : "= #{parent_item.node_id}"
    parent_item_sql = parent_item.nil? ? "IS NULL" : "= #{parent_item.id}"
    parent_item_count_sql =
      "(SELECT COUNT(*) FROM items WHERE items.request_id = #{request.id} AND " +
      "items.node_id = nodes.id AND items.parent_id #{parent_item_sql})"
    { :conditions => "nodes.parent_id #{parent_node_sql} AND " +
                     "nodes.item_quantity_limit > #{parent_item_count_sql}" }
  }

  has_and_belongs_to_many :document_types
  has_many :items
  belongs_to :structure
  belongs_to :category
  acts_as_tree

  validates_inclusion_of :requestable_type, :in => Node::ALLOWED_TYPES.values, :allow_blank => true
  validates_presence_of :category

  delegate :may_update?, :to => :structure
  delegate :may_see?, :to => :structure

  def may_create?(user)
    may_update? user
  end

  def may_destroy?(user)
    may_update? user
  end

  def to_s
    name
  end

end

