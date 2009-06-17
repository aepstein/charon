class DurableGoodExpense < ActiveRecord::Base
  has_one :request_item, :as => :requestable
end

