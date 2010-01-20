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

    when /^the profile page for #{capture_model}$/
      polymorphic_path( [:profile,model($1)] )

    when /the login page/
      new_user_session_path

    when /the items page/
      request_items_path(Request.find(:first))

    when /the profile page/
      profile_path

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

