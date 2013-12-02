When(/^I click "(.*?)"$/) do |link_text|
  click_link_or_button link_text
end

When(/^I fill in a valid username and password$/) do
  fill_in :login, :with => 'bmatic'
  fill_in :password, :with => 'bmatic'
end

Then(/^I see that I'm logged in$/) do
  expect(page).to have_selector('.notice',:text => /successfully/)
end

When(/^I fill in an invalid username and password$/) do
  fill_in :login, :with => 'you'
  fill_in :password, :with => 'are not allowed'
end

