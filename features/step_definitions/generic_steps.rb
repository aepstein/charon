Given /^the following (.+) records?:$/ do |factory, table|
  table.hashes.each do |record|
    Factory(factory, record)
  end
end

Given /^([0-9]+) (.+) records?$/ do |number, factory|
  number.to_i.times do
    Factory(factory)
  end
end

