Given /^the following nodes:$/ do |nodes|
  nodes.hashes.each do |node_attributes|
    complex_attributes = Hash.new
    if node_attributes['structure'] then
      complex_attributes['structure'] = Structure.find_by_name(node_attributes['structure'])
    end
    if node_attributes['document_types'] then
      complex_attributes['document_types'] = node_attributes['document_types'].split(', ').map { |at| DocumentType.find_by_name( at.strip ) }
      complex_attributes['document_types'].each { |at| at.class.should == DocumentType }
    else
      complex_attributes['document_types'] = Array.new
    end
    Factory(:node,node_attributes.merge(complex_attributes))
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) node$/ do |pos|
  visit nodes_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following nodes:$/ do |nodes|
  nodes.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

