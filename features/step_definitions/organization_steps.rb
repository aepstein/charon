Given /the following (.+) eligible organizations:/ do |kind, organizations|
  organizations.hashes.each do |organization_attributes|
    organization = Factory(:organization, organization_attributes)
    organization.registrations << Factory(
      "#{kind}_eligible_registration".to_sym,
      { :name => organization.name }
    )
  end
end

