Given /^the following agreements:$/ do |agreements|
  Agreement.create!(agreements.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) agreement$/ do |pos|
  visit agreements_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following agreements:$/ do |expected_agreements_table|
  expected_agreements_table.diff!(table_at('table').to_a)
end
