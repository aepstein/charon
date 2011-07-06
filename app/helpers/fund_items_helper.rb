module FundItemsHelper
  def options_for_position(fund_item)
    ( fund_item.parent ? fund_item.parent.children : fund_item.fund_request.fund_items.root ).map { |i| [ i.title, i.position ] }
  end
end

