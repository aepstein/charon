Given /^an? ([a-z\s]+) email is sent for #{capture_model}$/ do |notice, context|
  notice[" "]= "_"
  "#{model(context).class.to_s}Mailer".constantize.send( "#{notice}", model(context) ).deliver
end

Then /^(?:I|they) should not see "([^"]*?)" in the email body$/ do |text|
  current_email.body.should_not include(text)
end

