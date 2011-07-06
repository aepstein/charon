module FundRequestsHelper

  def add_fund_request_fund_item_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :tasks, :partial => 'fund_request_fund_item',
                       :object => FundRequestFundItem.new
    end
  end

  def remove_link_unless_new_record(fields)
    out = ''
    out << fields.hidden_field(:_delete) unless fields.object.nil? || fields.object.new_record?
    out << link_to("remove", "##{fields.object.class.name.underscore}", :class => 'remove')
    out
  end

  # This method demonstrates the use of the :child_index option to render a
  # form partial for, for instance, client side addition of new nested
  # records.
  #
  # This specific example creates a link which uses javascript to add a new
  # form partial to the DOM.
  #
  # <% form_for @fund_request do |fund_request_form| -%>
  # <div id="fund_request_fund_items">
  # <% fund_request_form.fields_for :fund_request_fund_items do |fund_request_fund_item_form| %>
  # <%= render :partial => 'fund_request_fund_item', :locals => { :f => fund_request_fund_item_form } %>
  # <% end %>
  # </div>
  # <% end -%>


  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end

  end


  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options = {})
  end

end

