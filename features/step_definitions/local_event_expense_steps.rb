Given /^the following( reviewed)? local_event_expenses:$/ do |reviewed, local_event_expenses|
  local_event_expenses.hashes.each do |attributes|
    expense = create(:local_event_expense, attributes)
    if reviewed then
      expense.fund_edition.fund_item.fund_editions.reload
      expense.fund_edition.fund_item.fund_editions.next.save!
    end
  end
end

Then /^I should see the following local_event_expenses:$/ do |local_event_expenses_table|
  local_event_expenses_table.diff!(table_at('table').to_a)
end

