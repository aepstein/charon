module FundItemsHelper
  def options_for_displace_item(fund_edition)
    fund_edition.displaceable_items.map { |item| [ item.title, item.id ] }
  end
end

