Given /^there are no (.+)s$/ do |type|
  type.classify.constantize.delete_all
end

Given /^the following (.+) records?:$/ do |factory, table|
  table.hashes.each do |record|
    Factory(factory, record)
  end
end

Given /^([0-9]+) (.+) records?$/ do |number, factory|
  number.to_i.times do
    Factory(factory)
  end
end

Then /^I should see the following entries in "(.+)":$/ do |table_id, expected_approvals_table|
  expected_approvals_table.diff!(table_at("##{table_id}").to_a)
end

