# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_to_external_registration(organization)
    return organization.name unless organization.current_registration && organization.current_registration.external_id
    link_to organization.name, "http://sao.cornell.edu/SO/search.php?igroup=#{organization.current_registration.external_id}"
  end

  def link_to_registration(registration, text=nil)
    link_to( ( text ? text : registration.name ),
      "https://sao.cornell.edu/SO/org/#{registration.registration_term.short_description}/" +
      "#{registration.external_id}" )
  end

  def link_to_directory(user)
    return user.name unless user.net_id
    link_to user.name, "http://www.cornell.edu/search/index.cfm?tab=people&netid=#{user.net_id}"
  end

  def link_to_unapprove_fund_request(fund_request)
    approval = fund_request.approvals.where( :user_id => current_user.id).first
    if approval && permitted_to?( :destroy, approval )
      return link_to 'Unapprove', approval, :confirm => 'Are you sure?', :method => :delete
    end
    ''
  end

  def nested_index(parent, children, views=[])
    out = link_to( "List #{children}", polymorphic_path( [ parent, children ] ) )
    if views.length > 0
      out += ": ".html_safe + views.inject([]) do |memo, view|
        memo << link_to( view, polymorphic_path( [ view, parent, children ] ) )
        memo
      end.join(', ').html_safe
    end
    out.html_safe
  end

end

