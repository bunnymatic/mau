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
  expect(find('#secret-word-mailer button')).to be_present
end

When(/^I add a photo to upload$/) do
  attach_file 'Photo', Rails.root.join('spec/fixtures/files/profile.png')
end

When(%r{^I fill in the login form with "([^/]*)/([^"]*)"}) do |login, pass|
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
  expect(page).to have_flash :notice, /you're in/i
  within('.nav') do |nav|
    expect(nav).to have_content /my Account/i
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
  expect(page_body).to have_content 'Sign In'
  expect(page).to have_css('form.user_session')
end

When(/^I login$/) do
  step %(I visit the login page)
  # if we're already logged in we'll be somewhere else
  fill_in_login_form (@artist || @user).login, '8characters'
  step %(I click "Sign In")
  expect(page_body).to have_content /sign out/i
  step %(I close the flash)
end

When(/^I login as an artist$/) do
  step %(there are artists with art in the system)
  @artist = @artists.first
  step %(I login)
end

Then(/^I login as an editor$/) do
  @editor = FactoryBot.create(:user, :editor, :active)
  step %(I visit the login page)
  fill_in_login_form @editor.login, '8characters'
  step %(I click "Sign In")
end

When(/^I login as a manager$/) do
  studios = FactoryBot.create_list(:studio, 2)
  @manager = FactoryBot.create(:user, :manager, :active, studio: studios.first)
  step %(I visit the login page)
  fill_in_login_form @manager.login, '8characters'
  step %(I click "Sign In")
end

When(/^I login as an admin$/) do
  @administrator = FactoryBot.create(:user, :admin, :active)
  step %(I visit the login page)
  fill_in_login_form @administrator.login, '8characters'
  step %(I click "Sign In")
end

When(/^I'm logged out$/) do
  click_on_first 'sign out'
rescue Capybara::ElementNotFound => _e
end

When(/^I login as "(.*?)"$/) do |login|
  path = current_path
  path = '/' if path.nil? || path == ',' # comma comes from some capybara startup thing
  visit login_path
  @artist = User.find_by(login:)
  fill_in_login_form login, '8characters'
  steps %(And I click "Sign In")
  steps %(Then I see a flash notice "You're in")
  visit path
end

Then(/^I see my fan profile edit form$/) do
  expect(page).to have_css '.panel-heading', count: 5
end

Then /^I see that "(.*?)" is a new active artist$/ do |username|
  steps %(Then I see a flash notice "We're so excited to have you! Just sign in")
  expect(page).to have_current_path login_path
  expect(Artist.find_by(login: username)).to be_active
end

Then /^I see that "(.*?)" is a new fan$/ do |username|
  steps %(Then I see a flash notice "Thanks for signing up!")
  expect(page).to have_current_path login_path
  expect(MauFan.find_by(login: username)).to be_active
end

And /^mailchimp is handled$/ do
  resp = JSON.generate(email: 'example email',
                       euid: 'example euid',
                       leid: 'example leid')
  stub_request(:any, /.*\.mailchimp.com/).to_return(body: resp)
end

Then /^I click the fan signup button$/ do
  step 'mailchimp is handled'
  step 'I click "Sign up"'
end

Then(/^I see that I have been deactivated$/) do
  expect(@artist.state).to eql :suspended
end

Then(/^I click on the reset link in my email$/) do
  wait_until do
    open_email(@artist.email)
  end
  email = current_email.body
  reset_link = $1 if %r{(https?://.*/reset/.*)\s+} =~ email
  expect(reset_link).to be_present, 'Unable to find reset link in the email'
  visit reset_link
end

When(/^I visit a reset link with an unknown reset code$/) do
  visit 'http://test.host/reset/this-is-a-bogus'
end
