def fill_in_login_form(login, pass)
  fill_in("Login", :with => login)
  fill_in("Password", :with => pass)
end

When(/^I click (on\s+)?"(.*?)"$/) do |dummy, link_text|
  click_on link_text
end

When(/^I click (on\s+)?"(.*?)" in the menu$/) do |dummy, link_text|
  within('.nav') do
    click_on link_text
  end
end

When(/^I change my password to "(.*?)"$/) do |new_pass|
  visit edit_artist_path(@artist)
  fill_in("Old Password", :with => 'bmatic')
  fill_in("New Password", :with => new_pass)
  fill_in("Confirm new Password", :with => new_pass)
  click_on 'change password'
end

When(/^I fill in "(.*?)" for my password$/) do |pass|
  fill_in_login_form @artist.login, pass
end

When(/^I fill in valid credentials$/) do
  fill_in_login_form @artist.login, "bmatic"
end

Then(/^I see that I'm logged in$/) do
  expect(page).to have_selector('.flash__notice',:text => /you\'re in/i)
  within(".nav") do
    expect(page).to have_content 'my mau'
  end
end

Then(/^I see that I'm logged out$/) do
  within '.nav' do
    expect(page).to have_link "sign in", new_user_session_path
  end
end

When(/^I fill in an invalid username and password$/) do
  fill_in_login_form 'you', 'are not allowed'
end

When(/^I fill in my email/) do
  fill_in :user_email, :with => @artist.email
end

Then(/^I see the login page$/) do
  expect(current_path).to match login_path
end

When(/^I login$/) do
  steps %{When I visit the login page}
  # if we're already logged in we'll be somewhere else
  fill_in_login_form @artist.login, 'bmatic'
  steps %{And I click "Sign In"}
end

When(/^I login as an artist$/) do
  steps %{Given there are artists with art in the system}
  @artist = @artists.first
  steps %{When I login}
end

When(/^I login as an editor$/) do
  @editor = FactoryGirl.create(:user, :editor, :active)
  steps %{When I visit the login page}
  fill_in_login_form @editor.login, 'bmatic'
  steps %{And I click "Sign In"}
end

When(/^I login as a manager$/) do
  studios = FactoryGirl.create_list(:studio,2)
  @manager = FactoryGirl.create(:user, :manager, :active, :studio => studios.first)
  steps %{When I visit the login page}
  fill_in_login_form @manager.login, 'bmatic'
  steps %{And I click "Sign In"}
end

When(/^I login as "(.*?)"$/) do |login|
  fill_in_login_form login, 'bmatic'
  steps %{And I click "Sign In"}
end

Then /^I see that "(.*?)" is a new pending artist$/ do |username|
  steps %{Then I see a flash notice "Thanks for signing up! We're sending you an email"}
  expect(current_path).to eql root_path
  expect(Artist.find_by_login(username)).to be_pending
end
