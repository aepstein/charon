module FundItemsHelper
  def options_for_position(fund_item)
    ( fund_item.parent ? fund_item.parent.children : fund_item.fund_grant.fund_items.roots ).map { |i| [ i.title, i.position ] }
  end
end

