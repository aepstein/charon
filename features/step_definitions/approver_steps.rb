Given /^the following approvers:$/ do |approvers|
  approvers.hashes.each do |attributes|
    complex = Hash.new
    complex['role'] = Role.find_or_create_by_name(attributes['role']) if attributes['role']
    complex['framework'] = Framework.find_by_name(attributes['framework']) if attributes['framework']
    Factory( :approver, attributes.merge(complex) )
  end
end

When /^I delete "(.+)'s" (\d+)(?:st|nd|rd|th) approver$/ do |framework,pos|
  visit framework_approvers_url( Framework.find_by_name(framework) )
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following approvers:$/ do |expected_approvers_table|
  expected_approvers_table.diff!(table_at('table').to_a)
end

