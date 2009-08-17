Given /^the following documents:$/ do |documents|
  documents.hashes.each do |document_attributes|
    complex_attributes = Hash.new
    if document_attributes['version'] then
      complex_attributes['version'] = Version.all[ document_attributes['version'].to_i - 1 ]
    end
    if document_attributes['document_type'] then
      complex_attributes['document_type'] = DocumentType.find_by_name(document_attributes['document_type'])
    end
    Factory(:document, document_attributes.merge( complex_attributes ) )
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) document of the (\d+)(?:st|nd|rd|th) version$/ do |pos,version|
  visit version_documents_url( Version.all[ version.to_i - 1 ] )
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following documents:$/ do |documents|
  documents.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end

Then /all documents should be deleted/ do
  Document.all.each { |document| document.destroy }
end

