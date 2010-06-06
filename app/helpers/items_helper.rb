module ItemsHelper
  def options_for_position(item)
    ( item.parent ? item.parent.children : item.request.items.root ).map { |i| [ i.title, i.position ] }
  end
end

