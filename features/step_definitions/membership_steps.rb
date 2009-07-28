Given /^the following memberships:$/ do |memberships|
  memberships.hashes.each do |membership|
    complex_attrs = Hash.new
    complex_attrs['user'] = User.find_by_net_id(membership['user']) if membership.has_key?('user')
    complex_attrs['organization'] = Organization.find_by_last_name(membership['organization']) if membership.has_key?('organization')
    complex_attrs['role'] = Role.find_by_name(membership['role']) if membership.has_key?('role')
    Factory(:membership, membership.merge(complex_attrs))
  end
end

