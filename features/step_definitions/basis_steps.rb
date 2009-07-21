Given /^the following bases:$/ do |bases|
  #Basis.create!(bases.hashes)
  bases.hashes.each do |basis|
    Factory(:basis, basis)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) basis$/ do |pos|
  visit structure_bases_url(Structure.find(:first))
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following bases:$/ do |bases|
  bases.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

