Given /^the following organizations:$/ do |organizations|
  organizations.hashes.each do |organization_attributes|
    Factory(:organization, organization_attributes)
  end
end


Then /^I should see the following organizations:$/ do |expected_organizations_table|
  expected_organizations_table.diff!(table_at('table').to_a)
end

