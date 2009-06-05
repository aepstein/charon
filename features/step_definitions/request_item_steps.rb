Given /^the following request_items:$/ do |request_items|
  RequestItem.create!(request_items.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) request_item$/ do |pos|
  visit request_items_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following request_items:$/ do |request_items|
  request_items.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end
