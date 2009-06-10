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
end

#  def add_task_link(name, form)
  #  link_to_function name do |page|
  #    task = render(:partial => 'node_form', :locals => { :pf => form })
  #    page << %{
#var new_task_id = "new_" + new Date().getTime();
#$('tasks').insert({ bottom: "#{ escape_javascript task }".replace(/new_\\d+/g, new_task_id) });
#}
 #   end
  #end

