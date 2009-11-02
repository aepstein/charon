Given /^the following editions:$/ do |editions|
  editions.hashes.each do |edition_attributes|
    complex_attributes = Hash.new
    if edition_attributes['item']
      complex_attributes['item'] = Item.all[ edition_attributes['item'].to_i - 1 ]
    end
    Factory(:edition, edition_attributes.merge(complex_attributes) )
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) edition$/ do |pos|
  visit editions_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following editions:$/ do |expected_editions_table|
  expected_editions_table.diff!(table_at('table').to_a)
end

