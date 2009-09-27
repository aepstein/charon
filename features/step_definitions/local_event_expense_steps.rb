Given /^the following( reviewed)? local_event_expenses:$/ do |reviewed, local_event_expenses|
  local_event_expenses.hashes.each do |attributes|
    expense = Factory(:local_event_expense, attributes)
    if reviewed then
      expense.version.item.versions.next( expense.version.attributes.merge( :local_event_expense_attributes => expense.attributes ) ).save!
    end
  end
end

Then /^I should see the following local_event_expenses:$/ do |local_event_expenses_table|
  local_event_expenses_table.diff!(table_at('table').to_a)
end

