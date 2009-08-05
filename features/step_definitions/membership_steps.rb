Given /^the following memberships:$/ do |memberships|
  memberships.hashes.each do |membership|
    complex_attrs = Hash.new
    complex_attrs['user'] = User.find_by_net_id(membership['user']) if membership['user']
    complex_attrs['role'] = Role.find_by_name(membership['role']) if membership['role']
    complex_attrs['organization'] = Organization.find_by_last_name(membership['organization']) if membership['organization']
    complex_attrs['registration'] = Registration.find_by_name(membership['registration']) if membership['registration']
    Factory(:membership, membership.merge(complex_attrs))
  end
end

