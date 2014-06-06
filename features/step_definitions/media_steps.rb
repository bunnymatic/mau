Then(/^I see the admin media list$/) do
  expect(current_path).to eql admin_media_path
end

When(/^I fill in "(.*?)" for "(.*?)"$/) do |arg1, arg2|
  fill_in arg2, :with => arg1
end

Then(/^I see the "(.*?)" as a medium$/) do |arg1|
  expect(page).to have_selector('.admin-table td.name', :text => arg1, :exact => true)
end
