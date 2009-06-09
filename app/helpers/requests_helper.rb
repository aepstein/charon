module RequestsHelper
  def add_item_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :items, :partial => 'item_form', :object => nil
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

