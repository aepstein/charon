Given /^the following frameworks:$/ do |frameworks|
  frameworks.hashes.each do |framework_attributes|
    Factory(:framework,framework_attributes)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) framework$/ do |pos|
  visit frameworks_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following frameworks:$/ do |frameworks|
  frameworks.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

