Given /^the following travel_event_expenses:$/ do |travel_event_expenses|
  TravelEventExpense.create!(travel_event_expenses.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) travel_event_expense$/ do |pos|
  visit travel_event_expenses_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following travel_event_expenses:$/ do |travel_event_expenses|
  travel_event_expenses.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.should == cell
      }
    end
  end
end
