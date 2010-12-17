# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def markdown( content )
    sanitize Markdown.new(content).to_html
  end

  def table_row_tag(increment=true, &block)
    content_tag 'tr', capture(&block), :class => table_row_class(increment)
  end

  def table_row_class(increment=true)
    @table_row_class ||= 'row1'
    out = @table_row_class
    @table_row_class = ( @table_row_class == 'row1' ? 'row2' : 'row1' ) if increment
    @table_row_class = 'row1' if increment == :reset
    out
  end

  def link_to_external_registration(organization)
    return organization.name unless organization.registrations.current && organization.registrations.current.external_id
    link_to organization.name, "http://sao.cornell.edu/SO/search.php?igroup=#{organization.registrations.current.external_id}"
  end

  def link_to_directory(user)
    return user.name unless user.net_id
    link_to user.name, "http://www.cornell.edu/search/index.cfm?tab=people&netid=#{user.net_id}"
  end

  def link_to_unapprove_request(request)
    approval = request.approvals.where( :user_id => current_user.id).first
    if approval && permitted_to?( :destroy, approval )
      return link_to 'Unapprove', approval, :confirm => 'Are you sure?', :method => :delete
    end
    ''
  end

  def nested_index(parent, children, views=[])
    out = link_to( "List #{children}", polymorphic_path( [ parent, children ] ) )
    if views.length > 0
      out += ": " + views.inject([]) do |memo, view|
        memo << link_to( h( view ), polymorphic_path( [ view, parent, children ] ) )
        memo
      end.join(', ')
    end
    raw( out )
  end

end

