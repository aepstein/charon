Given(/^#{capture_model} (?:has|have) #{capture_fields}$/) do |name, fields|
  subject = model(name)
  parse_fields(fields).each { |field, value| subject.send( "#{field}=", value ) }
  subject.save!
end

Given /^#{capture_model} is (closed|current|upcoming)$/ do |name, state|
  subject = model(name)
  case state
  when 'closed'
    subject.update_attributes! :open_at => Time.zone.now - 1.year,
      :closed_at => Time.zone.now - 1.day
  when 'current'
#    subject.update_attributes! :open_at => Time.zone.now - 1.year,
#      :closed_at => Time.zone.now + 1.month
  when 'upcoming'
    subject.update_attributes! :open_at => Time.zone.now + 1.month,
      :closed_at => Time.zone.now + 1.year
  end
end

Given /^#{capture_model} is destroyed$/ do |name|
  model(name).destroy
end

Given /^(?:|I )(put|post|delete) on (.+)$/ do |method, page_name|
#  visit path_to(page_name), method.to_sym
  # TODO this only works with the rack driver
  Capybara.current_session.driver.submit method.to_sym, path_to(page_name), {}
end

Then /^I should see authorized$/ do
  step %{I should not see "You are not allowed to perform the requested action."}
end

Then /^I should not see authorized$/ do
  step %{I should see "You are not allowed to perform the requested action."}
end

When /^I follow "(.+)" for the (\d+)(?:st|nd|rd|th) #{capture_factory}(?: for #{capture_model})?$/ do |link, position, subject, context|
  visit polymorphic_path( [ ( context.blank? ? nil : model(context) ), subject.pluralize ] )
  within("table > tbody > tr:nth-child(#{position.to_i})") do
    click_link "#{link}"
  end
end

Then /^I should( not)? see the following #{capture_plural_factory}:$/ do |negate, context, table|
  if negate.blank?
    table.diff!( tableish( 'table > thead,tbody > tr', 'th,td' ) )
  else
    # TODO: Ideally should verify table is not identical
  end
end

Given /^there are no (.+)s$/ do |type|
  type.classify.constantize.delete_all
end

Given /^the following (.+) records?:$/ do |factory, table|
  table.hashes.each do |record|
    create(factory, record)
  end
end

Given /^([0-9]+) (.+) records?$/ do |number, factory|
  number.to_i.times do
    create(factory)
  end
end

Given /^([0-9])+ seconds? elapses?$/ do |seconds|
  sleep seconds.to_i
end

Given /^the (.+) records? changes?$/ do |type|
  type.constantize.all.each { |o| o.touch }
end

Given /^I pause$/ do
  print "Press Return to continue ..."
  STDIN.getc
end

# set up a many to many association
Given(/^#{capture_model} is (?:in|one of|amongst) the (\w+) of #{capture_model}$/) do |target, association, owner|
  model(owner).send(association) << model(target)
end

Given(/^#{capture_model} is alone (?:in|one of|amongst) the (\w+) of #{capture_model}$/) do |target, association, owner|
  model(owner).send(association).delete_all
  model(owner).send(association) << model(target)
end

Given /^#{capture_model} is reloaded$/ do |target|
  model(target).reload
end

# assert model is in another model's has_many assoc
Then(/^#{capture_model} should be (?:in|one of|amongst) the (\w+) of #{capture_model}$/) do |target, association, owner|
  model(owner).send(association).should include(model(target))
end

# assert model is NOT in another model's has_many assoc
Then(/^#{capture_model} should not be (?:in|one of|amongst) the (\w+) of #{capture_model}$/) do |target, association, owner|
  model(owner).send(association).should_not include(model(target))
end

Then /^I should (not )?see the following entries in "(.+)":$/ do |negate, table_id, table|
  page.should have_selector(table_id)
  if negate.blank?
    table.diff!( tableish( "#{table_id} tr", 'th,td' ) )
  end
end

