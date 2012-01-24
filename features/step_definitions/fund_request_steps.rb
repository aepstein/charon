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

