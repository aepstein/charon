Given /^the following structures:$/ do |structures|
  structures.hashes.each do |structure_attributes|
    Factory(:structure, structure_attributes)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) structure$/ do |pos|
  visit structures_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following structures:$/ do |structures|
  structures.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

