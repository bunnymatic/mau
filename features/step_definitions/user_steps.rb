# frozen_string_literal: true

When(/^I change my password to "(.*?)"$/) do |new_pass|
  visit edit_artist_path(@artist)
  fill_in('Old Password', with: '8characters')
  fill_in('New Password', with: new_pass)
  fill_in('Confirm new Password', with: new_pass)
  click_on 'change password'
end

When(/^I set my new password to "(.*?)"$/) do |new_pass|
  fill_in('Password', with: new_pass, match: :prefer_exact)
  fill_in('Confirm Password', with: new_pass, match: :prefer_exact)
  click_on 'Reset Password'
end

When(/^I change my email to "(.*?)"$/) do |new_email|
  visit edit_artist_path(@artist)
  click_on 'Personal Info'
  fill_in('Email', with: new_email)
  click_on_first 'Save Changes'
end

Then('I see the secret word email link') do
  find(:link, 'contact us via email') do |link|
    expect(link['href']).to include('MAU.mailer')
    expect(link['href']).to include('Send me the secret word')
    expect(link.text).to include('email')
  end
end

When(/^I add a photo to upload$/) do
  attach_file 'Photo', Rails.root.join('spec', 'fixtures', 'files', 'profile.png')
end

When(%r{^I fill in the login form with "([^\/]*)\/([^\"]*)"}) do |login, pass|
  fill_in_login_form login, pass
end

When(/^I fill in "(.*?)" for my password$/) do |pass|
  fill_in_login_form @artist.login, pass
end

When(/^I fill in valid credentials using my email$/) do
  fill_in_login_form @artist.email, '8characters'
end

When(/^I fill in valid credentials$/) do
  fill_in_login_form @artist.login, '8characters'
end

Then(/^I see that I'm logged in$/) do
  expect(page).to have_flash :notice, /you\'re in/i
  within('.nav') do
    expect(page).to have_content 'My Account'
  end
end

Then(/^I see my photo in my profile$/) do
  within('.artist-profile__image') do
    expect(page.find('.profile')['src']).to include 'profile.png'
  end
end

Then(/^I see that I'm logged out$/) do
  within '.nav' do
    expect(page).to have_link 'sign in', href: '/login'
  end
end

When(/^I fill in an invalid username and password$/) do
  fill_in_login_form 'you', 'are not allowed'
end

When(/^I fill in my email/) do
  fill_in :user_email, with: @artist.email
end

Then(/^I see the login page$/) do
  expect(page).to have_content 'Sign In'
  expect(page).to have_css('form.user_session')
end

When(/^I login$/) do
  steps %(When I visit the login page)
  # if we're already logged in we'll be somewhere else
  fill_in_login_form (@artist || @user).login, '8characters'
  steps %(And I click "Sign In")
  expect(page).to have_content /sign out/i
end

When(/^I login as an artist$/) do
  steps %(Given there are artists with art in the system)
  @artist = @artists.first
  steps %(When I login)
end

When(/^I login as a fan$/) do
  steps %(Given there are users in the system)
  @user = MauFan.first
  steps %(When I login)
end

When(/^I login as an editor$/) do
  @editor = FactoryBot.create(:user, :editor, :active)
  steps %(When I visit the login page)
  fill_in_login_form @editor.login, '8characters'
  steps %(And I click "Sign In")
end

When(/^I login as a manager$/) do
  studios = FactoryBot.create_list(:studio, 2)
  @manager = FactoryBot.create(:user, :manager, :active, studio: studios.first)
  steps %(When I visit the login page)
  fill_in_login_form @manager.login, '8characters'
  steps %(And I click "Sign In")
end

When(/^I'm logged out$/) do
  logout_links = page.all('a[href*=logout]')
  logout_links.first.click if logout_links.present?
end

When(/^I login as "(.*?)"$/) do |login|
  path = current_path
  path = '/' if path.nil? || path == ',' # comma comes from some capybara startup thing
  visit login_path
  @artist = User.find_by(login: login)
  fill_in_login_form login, '8characters'
  steps %(And I click "Sign In")
  steps %(Then I see a flash notice "You're in")
  visit path
end

Then(/^I see my fan profile edit form$/) do
  expect(page).to have_css '.panel-heading', count: 5
end

Then /^I see that "(.*?)" is a new pending artist$/ do |username|
  steps %(Then I see a flash notice "Thanks for signing up! We're sending you an email")
  expect(current_path).to eql root_path
  expect(Artist.find_by(login: username)).to be_pending
end

Then /^I see that "(.*?)" is a new fan$/ do |username|
  steps %(Then I see a flash notice "Thanks for signing up!")
  expect(current_path).to eql login_path
  expect(MauFan.find_by(login: username)).to be_active
end

Then /^I click the fan signup button$/ do
  resp = JSON.generate(email: 'example email',
                       euid: 'example euid',
                       leid: 'example leid')
  stub_request(:any, /.*\.mailchimp.com/).to_return(body: resp)
  step 'I click "Sign up"'
end

Then(/^I see that I have been deactivated$/) do
  expect(@artist.state).to eql :suspended
end

Then(/^I click on the reset link in my email$/) do
  open_email(@artist.email)
  email = current_email.body
  reset_link = $1 if %r{(https?://.*/reset/.*)\s+} =~ email
  expect(reset_link).to be_present, 'Unable to find reset link in the email'
  visit reset_link
end

When(/^I visit a reset link with an unknown reset code$/) do
  visit 'http://test.host/reset/this-is-a-bogus'
end
