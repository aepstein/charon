class Stage < ActiveRecord::Base
  has_many :versions
  acts_as_list
end

