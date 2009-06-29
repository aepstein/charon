class DurableGoodExpense < ActiveRecord::Base
  has_one :version, :as => :requestable
end

