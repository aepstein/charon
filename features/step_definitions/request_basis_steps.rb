Given /^the following request_bases:$/ do |request_bases|
  RequestBasis.create!(request_bases.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) request_basis$/ do |pos|
  visit request_bases_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following request_bases:$/ do |request_bases|
  request_bases.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end
