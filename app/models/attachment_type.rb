class AttachmentType < ActiveRecord::Base
  UNITS = %w( byte kilobyte megabyte gigabyte )

  include GlobalModelAuthorization

  has_and_belongs_to_many :nodes
  has_many :attachments

  validates_uniqueness_of :name
  validates_numericality_of :max_size_quantity, :greater_than => 0,
    :only_integer => true
  validates_inclusion_of :max_size_unit, :in => UNITS

  def max_size
    return nil unless max_size_quantity? && max_size_unit?
    max_size_quantity.send(max_size_unit)
  end

  def max_size_string
    return nil unless max_size_quantity? && max_size_unit?
    "#{max_size_quantity} #{(max_size_quantity == 1) ? max_size_unit : max_size_unit.pluralize}"
  end
end

