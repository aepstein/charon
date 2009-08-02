Given /^the following items:$/ do |items|
  items.hashes.each do |item_attributes|
    complex_attributes = Hash.new
    complex_attributes['node'] = Node.find_by_name(item_attributes['node']) if item_attributes['node']
    complex_attributes['request'] = Request.all[item_attributes['request'].to_i - 1] if item_attributes['request']
    Factory(:item, item_attributes.merge( complex_attributes ) )
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) item of the (\d+)(?:st|nd|rd|th) request$/ do |pos,request_id|
  visit request_items_url( Request.find( request_id ) )
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

