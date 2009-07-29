Given /^the following requests:$/ do |requests|
  requests.hashes.each do |request_attributes|
    complex_attributes = Hash.new
    if request_attributes['organizations'] then
      complex_attributes['organizations'] = request_attributes['organizations'].split(', ').map do |o|
        Organization.find_by_last_name(o)
      end
    end
    complex_attributes['basis'] = Basis.find_by_name(request_attributes['basis'].strip) if request_attributes['basis']
    Factory(:request, request_attributes.merge( complex_attributes ) )
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

