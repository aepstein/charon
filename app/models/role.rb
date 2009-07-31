class Role < ActiveRecord::Base
  has_many :memberships

  def to_s
    name
  end
end

