class Category < ActiveRecord::Base
  attr_accessible :name

  has_many :nodes, inverse_of: :category
  has_many :activity_accounts, inverse_of: :category

  validates :name, presence: true, uniqueness: true

  default_scope order { name }

  def to_s; name; end
end

