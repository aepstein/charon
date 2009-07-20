Given /^the following items:$/ do |items|
  items.hashes.each do |item|
    item_object = Factory(:item, item)
    item_object.node = Factory(:node)
    item_object.request.basis.structure.nodes << item_object.node
    item_object.save
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) item$/ do |pos|
  visit items_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following items:$/ do |items|
  items.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

