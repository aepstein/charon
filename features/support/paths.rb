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
    when /the new registered_membership_condition page/
      new_registered_membership_condition_path


    when /the items page/
      request_items_path(Request.find(:first))

    when /the new basis page/
      new_basis_path

    when /^"(.*)'s new request page"$/
      new_organization_request_path(Organization.find_by_last_name($1))

    when /^"(.*)'s requests page"$/
      organization_requests_path(Organization.find_by_last_name($1))

    when /the new item page/
      new_item_path

    when /the new node page/
      new_node_path

    when /the new structure page/
      new_structure_path

    when /the new local_event_expense page/
      new_local_event_expense_path

    when /the new publication_expense page/
      new_publication_expense_path

    when /the new travel_event_expense page/
      new_travel_event_expense_path

    when /the new administrative_expense page/
      new_administrative_expense_path

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

