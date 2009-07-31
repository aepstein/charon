Given /the following organizations:/ do |organizations|
  organizations.hashes.each do |organization_attributes|
    organization = Factory(:organization, organization_attributes)
  end
end

