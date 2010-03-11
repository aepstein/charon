module ItemsHelper
  def options_for_position(item)
    if item.parent.nil?
      items = item.request.items.root
    else
      items = item.parent.children
    end
    options_for_select( items.map { |i| [ i.title, i.position ] }, item.position )
  end
end

