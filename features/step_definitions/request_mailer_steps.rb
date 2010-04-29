Given /^an? ([a-z\s]+) email is sent for #{capture_model}$/ do |notice, context|
  notice[" "]= "_"
  "#{model(context).class.to_s}Mailer".constantize.send( "deliver_#{notice}", model(context) )
end

