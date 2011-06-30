class DocumentType < ActiveRecord::Base
  UNITS = %w( byte kilobyte megabyte gigabyte )

  attr_accessible :name, :max_size_quantity, :max_size_unit

  has_and_belongs_to_many :nodes
  has_many :documents, :inverse_of => :document_type

  validates :name, :presence => true, :uniqueness => true
  validates :max_size_quantity,
    :numericality => { :greater_than => 0, :only_integer => true }
  validates :max_size_unit, :inclusion => { :in => UNITS }

  default_scope order( 'document_types.name ASC' )

  def max_size
    return nil unless max_size_quantity? && max_size_unit?
    max_size_quantity.send(max_size_unit)
  end

  def max_size_string
    return nil unless max_size_quantity? && max_size_unit?
    "#{max_size_quantity} #{(max_size_quantity == 1) ? max_size_unit : max_size_unit.pluralize}"
  end

  def to_s; name; end
end

