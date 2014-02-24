When(/^I click (on\s+)?"(.*?)"$/) do |dummy, link_text|
  click_on link_text
end

When(/^I click (on\s+)?"(.*?)" in the menu$/) do |dummy, link_text|
  within('.nav') do
    click_on link_text
  end
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

When(/^I login$/) do
  steps %{When I visit the login page}
  fill_in :login, :with => @artist.login
  fill_in :password, :with => 'bmatic'
  steps %{And I click "Log in"}
end

When(/^I login as an editor$/) do
  @editor = FactoryGirl.create(:user, :editor, :active)
  steps %{When I visit the login page}
  fill_in :login, :with => @editor.login
  fill_in :password, :with => 'bmatic'
  steps %{And I click "Log in"}
end

When(/^I login as "(.*?)"$/) do |login|
  fill_in :login, :with => login
  fill_in :password, :with => 'bmatic'
  steps %{And I click "Log in"}
end
