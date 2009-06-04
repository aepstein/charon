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
    when /the new local_event_expense page/
      new_local_event_expense_path

    when /the new local_event_expense page/
      new_local_event_expense_path

    when /the new local_event_expenses page/
      new_local_event_expenses_path

    when /the new local_event_expenses page/
      new_local_event_expenses_path

    when /the new local_event_expenses page/
      new_local_event_expenses_path

    when /the new local_event_expense page/
      new_local_event_expense_path

    when /the new publication_expense page/
      new_publication_expense_path

    when /the new publication_expense page/
      new_publication_expense_path

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
