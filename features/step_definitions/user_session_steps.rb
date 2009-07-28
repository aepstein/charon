Given /^I am logged in as "(.*)" with password "(.*)"$/ do |net_id, password|
  unless net_id.blank?
   visit login_url
   fill_in( 'Net', :with => net_id )
   fill_in( 'Password', :with => password )
   click_button( 'Login' )
   response.should contain('Login successful!')
  end
end

