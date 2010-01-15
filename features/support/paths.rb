module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the homepage/
      '/'

    when /^the edit page for #{capture_model}$/
      edit_polymorphic_path( [model($1)] )

    when /^the new #{capture_factory} page$/
      new_polymorphic_path( [$1] )

    when /^the new #{capture_factory} page for #{capture_model}$/
      new_polymorphic_path( [model($2), $1] )

    when /^the #{capture_plural_factory} page$/
      polymorphic_path( [$1] )

    when /^the #{capture_plural_factory} page for #{capture_model}$/
      polymorphic_path( [model($2), $1] )

    when /^the page for #{capture_model}$/
      polymorphic_path( [model($1)] )

    when /^"(.+)'s new approver page"$/
      new_framework_approver_path( Framework.find_by_name($1) )

    when /the new document page of the (\d+)(?:st|nd|rd|th) edition/
      new_edition_document_path( Edition.all[ $1.to_i - 1 ] )

    when /the new edition page of the (\d+)(?:st|nd|rd|th) item/
      new_item_edition_path( Item.all[ $1.to_i - 1 ] )

    when /^"(.+)'s new permission page"$/
      new_framework_permission_path(Framework.find_by_name($1))

    when /^"(.+)'s edit user page"$/
      edit_user_path(User.find_by_net_id($1))

    when /^"(.+)'s show user page"$/
      user_path(User.find_by_net_id($1))

    when /the login page/
      new_user_session_path

    when /the items page/
      request_items_path(Request.find(:first))

    when /^"(.+)'s edit framework page"$/
      edit_framework_path( Framework.find_by_name($1) )

    when /^"(.+)'s bases page"$/
      organization_bases_path( Organization.find_by_last_name($1) )

    when /^"(.+)'s new basis page"$/
      new_organization_basis_path( Organization.find_by_last_name($1) )

    when /^"(.+)'s new request page"$/
      new_organization_request_path( Organization.find_by_last_name($1) )

    when /^"(.+)'s requests page"$/
      organization_requests_path( Organization.find_by_last_name($1) )

    when /^the "(.+)" basis requests page$/
      basis_requests_path( Basis.find_by_name($1) )

    when /the profile page/
      profile_path

    when /^"(.+)'s user profile page"$/
      profile_path

    when /^"(.+)'s organization profile page"$/
      profile_organization_path( Organization.find_by_last_name($1) )

    when /^"(.+)'s new node page"$/
      new_structure_node_path( Structure.find_by_name($1) )

    when /^"(.+)'s node page"$/
      structure_nodes_path( Structure.find_by_name($1) )

    when /the unauthorized page/
      unauthorized_path

    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)

