class Structure < ActiveRecord::Base
  attr_accessible :name

  default_scope order { name }

  has_many :nodes, inverse_of: :structure
  has_many :fund_sources, inverse_of: :structure
  has_many :categories, through: :nodes, uniq: true

  validates :name, presence: true, uniqueness: true

  def to_s; name; end

end

