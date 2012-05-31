class InventoryItem < ActiveRecord::Base
  attr_accessible :purchase_price, :current_value, :description, :identifier,
    :comments, :usable, :missing, :acquired_on, :scheduled_retirement_on,
    :retired_on
  attr_readonly :organization_id

  belongs_to :organization, inverse_of: :inventory_items

  has_paper_trail class_name: 'SecureVersion'

  scope :ordered, joins { organization }.order { [ organizations.last_name,
    organizations.first_name, identifier, acquired_on, description ] }
  scope :active, where( :retired_on => nil)
  scope :retired, where { retired_on != nil }
  scope :organization_name_contains, lambda { |name|
    scoped.merge( Organization.name_contains( name ) )
  }

  validates :organization, presence: true
  validates :identifier, uniqueness: { scope: [ :organization_id ] }
  validates :purchase_price,
    numericality: { greater_than_or_equal_to: 0.0 }
  validates :current_value, numericality: { greater_than_or_equal_to: 0.0 }
  validates :description, presence: true
  validates :acquired_on, timeliness: { type: :date }
  validates :scheduled_retirement_on,
    timeliness: { type: :date, after: :acquired_on }
  validates :retired_on, timeliness: { type: :date, allow_blank: true,
    after: :acquired_on }

  before_validation :initialize_current_value, on: :create

  def to_s; description + ( identifier? ? " (#{identifier})" : "" ); end

  private

  def initialize_current_value
    self.current_value ||= purchase_price
  end

end

