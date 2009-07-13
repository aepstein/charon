Given /^the following requests:$/ do |requests|
  requests.hashes.each do |request|
    if request.has_key?('organizations')
      organizations = request['organizations'].split(', ').map { |o| Organization.find_by_last_name(o.strip) }
      request.delete('organizations')
    end
    request_object = Factory.build('request', request)
    request_object.organizations << organizations
    request_object.save
  end
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

