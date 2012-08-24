Given(/^I select "(.+)" for the "(.+)" of #{capture_model} in place$/) do |value, field, name|
  subject = model(name)
  bip_select(model(name), field, value)
end

