class Node < ActiveRecord::Base
  ALLOWED_TYPES = {
    'Administrative' => 'AdministrativeExpense',
    'Durable Good' => 'DurableGoodExpense',
    'Local Event' => 'LocalEventExpense',
    'Publication' => 'PublicationExpense',
    'Travel Event' => 'TravelEventExpense'
  }

  has_many :items
  belongs_to :structure
  acts_as_tree

  validates_inclusion_of :requestable_type, :in => Node::ALLOWED_TYPES.values
end

