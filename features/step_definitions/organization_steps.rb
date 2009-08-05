Given /the following organizations:/ do |organizations|
  organizations.hashes.each do |organization_attributes|
    Factory(:organization, organization_attributes)
  end
end

