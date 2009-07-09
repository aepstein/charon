Given /^the following registrations:$/ do |registrations|
  Registration.create!(registrations.hashes)
  registrations.hashes.each do |registration|
    if registration.has_key?('organization')
      registration[:organization_id] = Organization.find_by_last_name(registration['organization'])
      registration.delete('organization')
    end
    Factory(:registrations, registration)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) registration$/ do |pos|
  visit registrations_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following registrations:$/ do |registrations|
  registrations.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

