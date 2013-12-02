Then /^show me the page$/ do
  save_and_open_page
end

When /I visit the login page/ do
  visit '/login'
end

Then(/^I see an error message "(.*?)"$/) do |msg|
  expect(page).to have_content msg
end
