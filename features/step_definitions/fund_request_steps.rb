Then /^I should see (#{capture_model}|"None available") for the deadline$/ do |pattern, queue_model|
  if pattern == %{"None available"}
    pattern = "None available"
  else
    queue = model(queue_model)
    queue.class.should eql FundQueue
    pattern = queue.to_s
  end
  step %{I should see "Deadline: #{pattern}"}
end

# create a model
Given(/^#{capture_model} exists? after #{capture_model}(?: with #{capture_fields})?$/) do |name, after, fields|
  date = model(after).submit_at + 1.day
  effective_fields = ( fields.blank? ? "" : "#{fields}, " ) + "submit_at: \"#{date.to_s :db}\"" +
    ", release_at: \"#{(date + 1.week).to_s :db}\""
  create_model(name, effective_fields)
end

