class Basis < ActiveRecord::Base
  KINDS = %w( safc gpsafc )

  belongs_to :structure
  has_many :requests

  validates_presence_of :structure
  validates_inclusion_of :kind, :in => KINDS

  def name
    "#{structure.name} beginning at #{open_at.to_s}"
  end
end

