Given /^the following approvals:$/ do |approvals|
  approvals.hashes.each do |attributes|
    local = Hash.new
    attributes.each { |k,v| local[k] = v }
    if local['agreement'] && !(local['agreement'].blank?)
      local['approvable'] = Agreement.find_by_name(local['agreement'])
      local.delete('agreement')
    end
    local['user'] = User.find_by_net_id(local['user']) if local['user']
    Factory(:approval, local)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) approval$/ do |pos|
  visit approvals_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following approvals:$/ do |expected_approvals_table|
  expected_approvals_table.diff!(table_at('table').to_a)
end

