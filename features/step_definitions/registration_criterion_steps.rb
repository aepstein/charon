When /^I delete the (\d+)(?:st|nd|rd|th) registration_criterion$/ do |pos|
  visit registration_criterions_url
  within("table > tbody tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following registration_criterions:$/ do |expected_registration_criterions_table|
  expected_registration_criterions_table.diff!(tableish('table tr', 'td,th'))
end

