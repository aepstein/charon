Given /^the following permissions:$/ do |permissions|
  permissions.hashes.each do |permission|
    permission[:role] = Role.find_by_name(permission['role']) if permission.has_key?('role')
    permission[:framework] = Framework.find_by_name(permission['framework']) if permission.has_key?('framework')
    Factory(:permission, permission)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) permission$/ do |pos|
  visit permissions_url
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

