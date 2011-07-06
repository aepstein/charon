When /^I move the (\d+)(?:st|nd|rd|th) fund_item$/ do |position|
  within("table > tbody > tr:nth-child(#{1 + (position.to_i - 1)*2})") do
    click_link "Move"
  end
end

