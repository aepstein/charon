Given /^the following addresses:$/ do |addresses|
  addresses.hashes.each do |attributes|
    complex = Hash.new
    complex['addressable'] = User.find_by_net_id(attributes['addressable']) if attributes['addressable']
    Factory( :address, attributes.merge(complex) )
  end
end

When /^I delete "(.+)'s" (\d+)(?:st|nd|rd|th) address$/ do |user, pos|
  visit user_addresses_url( User.find_by_net_id(user) )
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following addresses:$/ do |expected_addresses_table|
  expected_addresses_table.diff!(table_at('table').to_a)
end

