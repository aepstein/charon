class InventoryItem < ActiveRecord::Base
  attr_accessible :purchase_price, :current_value, :description, :identifier,
    :comments, :usable, :missing, :acquired_on, :scheduled_retirement_on,
    :retired_on
  attr_readonly :organization_id

  belongs_to :organization, :inverse_of => :inventory_items

  has_paper_trail :class_name => 'SecureVersion'

  default_scope includes(:organization).
    order( 'organizations.last_name ASC, organizations.first_name ASC, ' +
    'inventory_items.identifier ASC, inventory_items.acquired_on ASC, ' +
    'inventory_items.description ASC' )

  scope :active, where( :retired_on => nil)
  scope :retired, where( :retired_on.ne => nil )
  scope :organization_name_contains, lambda { |name|
    scoped.merge( Organization.name_contains( name ) )
  }

  search_methods :organization_name_contains

  validates_presence_of :organization
  validates_uniqueness_of :identifier, :scope => [ :organization_id ]
  validates_numericality_of :purchase_price, :greater_than_or_equal_to => 0.0
  validates_numericality_of :current_value, :greater_than_or_equal_to => 0.0
  validates_presence_of :description
  validates_date :acquired_on
  validates_date :scheduled_retirement_on, :after => :acquired_on
  validates_date :retired_on, :allow_blank => true, :after => :acquired_on

  before_validation :initialize_current_value, :on => :create

  def to_s; description + ( identifier? ? " (#{identifier})" : "" ); end

  private

  def initialize_current_value
    self.current_value ||= purchase_price
  end

end

