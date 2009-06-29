class Basis < ActiveRecord::Base
  belongs_to :structure
  has_many :requests

  validates_presence_of :structure

  def name
    "#{structure.name} beginning at #{open_at.to_s}"
  end
end

