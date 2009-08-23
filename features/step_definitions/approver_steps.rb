Given /^the following approvers:$/ do |approvers|
  Approver.create!(approvers.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) approver$/ do |pos|
  visit approvers_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following approvers:$/ do |expected_approvers_table|
  expected_approvers_table.diff!(table_at('table').to_a)
end
