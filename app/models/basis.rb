class Basis < ActiveRecord::Base
  belongs_to :structure
  has_many :requests

  validates_presence_of :structure
end

