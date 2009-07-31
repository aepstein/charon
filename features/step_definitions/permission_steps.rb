Given /^the following permissions:$/ do |permissions|
  permissions.hashes.each do |permission|
    complex_attrs = Hash.new
    complex_attrs['framework'] = Framework.find_by_name(permission['framework']) if permission.has_key?('framework')
    complex_attrs['role'] = Role.find_by_name(permission['role']) if permission.has_key?('role')
    Factory(:permission, permission.merge(complex_attrs))
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) permission for "(.+)"$/ do |pos, framework|
  visit framework_permissions_url( Framework.find_by_name( framework ) )
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following permissions:$/ do |permissions|
  permissions.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

