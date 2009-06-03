Given /^the following administrative_expenses:$/ do |administrative_expenses|
  AdministrativeExpense.create!(administrative_expenses.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) administrative_expense$/ do |pos|
  visit administrative_expenses_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following administrative_expenses:$/ do |administrative_expenses|
  administrative_expenses.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end
