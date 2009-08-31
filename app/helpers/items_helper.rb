module ItemsHelper
  def options_for_position(item)
    if item.parent.nil?
      items = item.request.items
    else
      items = parent.items
    end
    options_for_select( items.map { |i| [ i.title, i.id ] }, item.position )
  end
end

