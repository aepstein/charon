Given /^the following requests:$/ do |requests|
  requests.hashes.each do |request_attributes|
    if request_attributes.has_key?('organizations') then
      organizations = request_attributes['organizations'].split(', ').map do |o|
        Organization.find_by_last_name(o.strip)
      end
      organizations.each { |o| o.class.should == Organization }
      attributes = request_attributes.merge( { 'organizations' => organizations } )
    else
      attributes = request_attributes
    end
    Factory('request', attributes)
  end
end

When /^I select basis ([0-9]+) as the basis$/ do |id|
  select(Basis.find(id).name, :from => "request[basis_id]")
end

When /^I delete the (\d+)(?:st|nd|rd|th) request$/ do |pos|
  visit requests_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following requests:$/ do |requests|
  requests.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

