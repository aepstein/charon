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

    when /the new version page of the (\d+)(?:st|nd|rd|th) item/
      new_item_version_path( Item.all[ $1.to_i - 1 ] )

    when /the new role page/
      new_role_path


    when /the new framework page/
      new_framework_path

    when /^"(.+)'s new permission page"$/
      new_framework_permission_path(Framework.find_by_name($1))

    when /the new user page/
      new_user_path

    when /^"(.+)'s edit user page"$/
      edit_user_path(User.find_by_net_id($1))

    when /^"(.+)'s show user page"$/
      user_path(User.find_by_net_id($1))

    when /the new registration page/
      new_registration_path

    when /the login page/
      new_user_session_path

    when /the items page/
      request_items_path(Request.find(:first))

    when /^"(.+)'s edit framework page"$/
      edit_framework_path( Framework.find_by_name($1) )

    when /^"(.+)'s basis page"$/
      structure_bases_path( Structure.find_by_name($1) )

    when /^"(.+)'s new basis page"$/
      new_structure_basis_path( Structure.find_by_name($1) )

    when /^"(.+)'s new request page"$/
      new_organization_request_path( Organization.find_by_last_name($1) )

    when /^"(.+)'s requests page"$/
      organization_requests_path( Organization.find_by_last_name($1) )

    when /the requests page/
      requests_path

    when /^"(.+)'s organization profile page"$/
      profile_organization_path( Organization.find_by_last_name($1) )

    when /the new item page/
      new_item_path

    when /^"(.+)'s new node page"$/
      new_structure_node_path( Structure.find_by_name($1) )

    when /^"(.+)'s node page"$/
      structure_nodes_path( Structure.find_by_name($1) )

    when /the new structure page/
      new_structure_path

    when /the structures page/
      structures_path

    when /the new local_event_expense page/
      new_local_event_expense_path

    when /the new publication_expense page/
      new_publication_expense_path

    when /the new travel_event_expense page/
      new_travel_event_expense_path

    when /the new administrative_expense page/
      new_administrative_expense_path

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

