Given /^the following document_types:$/ do |document_types|
  document_types.hashes.each do |document_type_attributes|
    Factory(:document_type, document_type_attributes)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) document_type$/ do |pos|
  visit document_types_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following document_types:$/ do |document_types|
  document_types.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

