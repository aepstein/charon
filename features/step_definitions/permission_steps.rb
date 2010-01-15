Given /^the following permissions:$/ do |permissions|
  permissions.hashes.each do |permission|
    complex = Hash.new
    complex['framework'] = Framework.find_by_name(permission['framework']) if permission['framework']
    complex['role'] = Role.find_by_name(permission['role']) if permission['role']
    Factory(:permission, permission.merge(complex))
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

