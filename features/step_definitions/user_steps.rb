When(/^I click "(.*?)"$/) do |link_text|
  click_link_or_button link_text
end

When(/^I fill in valid credentials$/) do
  fill_in :login, :with => @artist.login
  fill_in :password, :with => 'bmatic'
end

Then(/^I see that I'm logged in$/) do
  expect(page).to have_selector('.notice',:text => /successfully/)
end

When(/^I fill in an invalid username and password$/) do
  fill_in :login, :with => 'you'
  fill_in :password, :with => 'are not allowed'
end

When(/^I fill in my email/) do
  fill_in :user_email, :with => @artist.email
end

Then(/^I see the login page$/) do
  expect(current_path).to match login_path
end
