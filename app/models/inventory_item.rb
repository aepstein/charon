class InventoryItem < ActiveRecord::Base
  default_scope :order => 'organizations.last_name ASC, organizations.first_name ASC, inventory_items.identifier ASC, ' +
    'inventory_items.acquired_on ASC, inventory_items.description ASC', :include => :organization

  scope_procedure :active, lambda { retired_on_null }
  scope_procedure :retired, lambda { retired_on_not_null }

  belongs_to :organization

  validates_presence_of :organization
  validates_uniqueness_of :identifier, :scope => [ :organization_id ]
  validates_numericality_of :purchase_price, :greater_than_or_equal_to => 0.0
  validates_numericality_of :current_value, :greater_than_or_equal_to => 0.0
  validates_presence_of :description
  validates_date :acquired_on
  validates_date :scheduled_retirement_on, :after => :acquired_on
  validates_date :retired_on, :allow_blank => true, :after => :acquired_on

  before_validation_on_create { |r| r.current_value ||= r.purchase_price }

  def to_s; description + ( identifier? ? " (#{identifier})" : "" ); end

end

