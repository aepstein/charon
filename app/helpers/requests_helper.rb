module RequestsHelper

  def fields_for_item(item, &block)
    prefix = item.new_record? ? 'new' : 'existing'
    fields_for("request[#{prefix}_request_items][]", item, &block)
    #fields_for("request[request_items][]", item, &block)
  end

  def add_item_link(text, element_id)
    link_to_function text do |page|
      page.insert_html :bottom, element_id, :partial => 'item_form', :object => RequestItem.new
    end
  end

  def add_item_link_2(link_text, element_id)
    link_to_function link_text do |page|
      item = render(:partial => 'item_form', :object => RequestItem.new)
      page << %{
var new_item_id = "new_" + new Date().getTime();
$('items').insert({ bottom: "#{ escape_javascript item }".replace(/new_\\d+/g, new_item_id) });
}
    end
  end

end

