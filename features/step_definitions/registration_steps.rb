Given /^the following registrations:$/ do |registrations|
  registrations.hashes.each do |registration|
    complex_attributes = Hash.new
    if registration['organization'] then
      complex_attributes['organization'] = Organization.find_by_last_name(registration['organization'])
    end
    Factory(:registration, registration.merge( complex_attributes ) )
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) registration$/ do |pos|
  visit registrations_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following registrations:$/ do |expected_registrations_table|
  expected_registrations_table.diff!(table_at('table').to_a)
end

