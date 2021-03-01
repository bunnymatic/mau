require_relative '../../spec/support/mobile_setup'

def fill_in_login_form(login, pass)
  fill_in('Username/Email', with: login)
  fill_in('Password', with: pass)
end

def path_from_title(titleized_path_name)
  clean_path_name = titleized_path_name.downcase.tr(' ', '_')
  path_helper_name = "#{clean_path_name}_path".to_sym
  send(path_helper_name)
end

def find_first_link_or_button(locator)
  find_links_or_buttons(locator).first
end

def find_last_link_or_button(locator)
  find_links_or_buttons(locator).last
end

# careful here with JS.  these don't "wait for" things to show up
# so invisible buttons that may become visible because of animation
# will cause issues - use click_on instead
def all_links_or_buttons_with_title(title)
  all('a').select { |a| a['title'] == title } ||
    all('button').select { |b| b.value == title }
end

def find_links_or_buttons(locator)
  result = all("##{locator}") if /^-_[A-z][0-9]*$/.match?(locator)
  return result if result.present?

  result = all('a,button', text: locator)
  return result if result.present?

  all_links_or_buttons_with_title(locator)
end

Given /^the cache is clear$/ do
  Rails.cache.clear
end

When /I'm on my smart phone/ do
  current_session.header('User-Agent', IPHONE_USER_AGENT)
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^I (save and\s+)?open the page$/ do |_|
  save_and_open_page
end

Then /^I (save|take) a screenshot$/ do |_dummy|
  f = File.expand_path("./tmp/capybara-screenshot-#{Time.current.to_f}.png")
  begin
    save_and_open_screenshot(f)
  rescue Capybara::NotSupportedByDriverError
    f = f.gsub /png$/, 'html'
    puts "Screenshot not supported - saving html to #{f}"
    save_page(f)
  end
end

Then /^I save and open a screenshot$/ do
  save_and_open_screenshot
end

When /I visit the login page/ do
  visit login_path
end

When /I visit the signup page/ do
  visit signup_path
end

When /I visit the fan signup page/ do
  visit signup_path(type: MauFan.name)
end

When /I sign in with password "(.*?)"/ do |pass|
  visit login_path
  fill_in_login_form @artist.login, pass
  click_on 'Sign In'
end

When /I am signed in as an artist/ do
  steps %(
    Given an account has been created
    Given I visit the login page
    When I fill in valid credentials
    And I click "Sign In"
  )
end

Then /^I see "(.*?)" on the page$/ do |content|
  expect(page).to have_content content
end

When /^I (log|sign)\s?out$/ do |_dummy|
  visit logout_path
  expect(page).to have_content /sign in/i
  expect(page).to have_flash :notice, /make some art/
end

Then /^I see that I'm signed in$/ do
  expect(page).to have_content 'MY PROFILE'
end

When(/^I change "(.*?)" to "(.*?)" in the "(.*?)" form$/) do |form_field_label, value, form_selector|
  within form_selector do
    fill_in form_field_label, with: value
  end
end

When(/^I fill in "(.*?)" for "(.*?)"$/) do |arg1, arg2|
  step "I change \"#{arg2}\" to \"#{arg1}\""
end

When(/^I change "(.*?)" to "(.*?)"$/) do |form_field_label, value|
  fill_in form_field_label, with: value
end

Then(/my "(.*?)" is "(.*?)" in the "(.*?)" section of the form/) do |form_field_label, value, section|
  step "I click on \"#{section}\""
  expect(page).to have_selector 'form.formtastic'
  expect(find_field(form_field_label).value).to eql value
end

Then(/^I see that the studio "(.*?)" has an artist called "(.*?)"$/) do |studio_name, user_login|
  expect(Studio.where(name: studio_name).first.artists).to include User.where(login: user_login).first
end

Then(/^I see an error in the form "(.*?)"$/) do |msg|
  within first('form', minimum: 1) do
    expect(page).to have_selector '.error', text: msg
  end
end

Then(/^I do not see "(.*?)"/) do |string|
  expect(page).to_not have_content(string)
end

Then(/^I do not see an error message$/) do
  expect(page).to_not have_selector '.error-msg, .flash__error, .err'
end

Then(/^I see an error message "(.*?)"$/) do |msg|
  expect(page).to have_selector '.error-msg', text: msg
end

Then(/^I see a flash error (including\s+)?"(.*?)"$/) do |_, msg|
  expect(page).to have_flash(:error, Regexp.new(msg))
end

Then(/^I see a flash notice (including\s+)?"(.*?)"$/) do |_, msg|
  expect(page).to have_flash(:notice, Regexp.new(msg))
end

Then(/^I close the notice$/) do
  find('.flash.flash__notice .flash__close').trigger 'click'
rescue Capybara::NotSupportedByDriverError
  find('.flash.flash__notice .flash__close').click
end

Then(/^I close the flash$/) do
  all('.flash .js-flash__close').each(&:click)
end

When(/^I visit the "(.*?)" page$/) do |titleized_path_name|
  visit path_from_title(titleized_path_name)
end

When(/^I visit "(.*?)"$/) do |path|
  visit path
end

Then(/^I see the "(.*?)" page$/) do |titleized_path_name|
  expect(current_path).to eql path_from_title(titleized_path_name)
end

When(/^I click (on\s+)?"([^"]*)"$/) do |_, link_text|
  click_on link_text
end

When(/^I click on "(.*?)" in the "(.*?)"$/) do |link, container|
  within container do
    click_on_first link, visible: false
  end
end

When(/^I click on "(.*?)" in the admin menu$/) do |link_title|
  if running_js?
    if all('#admin_nav').count.positive?
      find('#admin_nav .handle').hover
      el = all('#admin_nav a', text: link_title).first
    else
      el = all('.pure-menu a', text: link_title).first
    end
    el.click
  else
    step %(I click on "#{link_title}" in the ".admin .pure-menu, #admin_nav")
  end
end

When(/^I click on "(.*?)" in the sidebar menu$/) do |link_title|
  step %(I click on "#{link_title}" in the ".nav.nav-tabs")
end

When(/^I click on the first "([^"]*?)"$/) do |button_text|
  click_on(button_text, match: :first)
end

When(/^I click on the first "([^"]*?)" (button|link)$/) do |button_text, _dummy|
  click_on(button_text, match: :first)
end

When(/^I click on the last "([^"]*?)" (button|link)$/) do |button_text, _dummy|
  all(:link_or_button, button_text).last.click
end

def fill_in_field_with_value(field, value)
  # First try with a label
  xpath = ".//label[normalize-space(translate(.,'*',''))='#{field}' or @for='#{field}']/.."
  if page.all(:xpath, xpath).empty?
    # Then try with a input field
    xpath = ".//input[@type='text' and (@id='#{field}' or @name='#{field}')]/.."
  end

  within(:xpath, xpath) do
    fill_in(field, with: value)
  end
end

When(/^I fill in the form with:$/) do |table|
  info = table.hashes.first
  info.each do |field, val|
    if /Studio/.match?(field)
      select val, from: field
    else
      fill_in_field_with_value field, val
    end
  end
end

When(/^I fill in the "([^"]*?)" form with:$/) do |form_locator, table|
  within form_locator do
    info = table.hashes.first
    info.each do |field, val|
      if /Studio/.match?(field)
        select val, from: field
      else
        fill_in_field_with_value field, val
      end
    end
  end
end

Then(/^I see the "([^"]*?)" form has:$/) do |form_locator, table|
  within form_locator do
    info = table.hashes.first
    info.each do |field, val|
      expect(find_field(field).value).to eql val
    end
  end
end

When(/^I choose "([^"]*?)" from "(.*?)"$/) do |option, select|
  select option, from: select
end

When /^I choose "([^"]*?)"$/ do |radio|
  choose radio
end

When /^I check "([^"]*?)"$/ do |cb|
  check cb, visible: false
end

When /^I uncheck "([^"]*?)"$/ do |cb|
  uncheck cb, visible: false
end

Then(/^I click on the "([^"]*)" icon$/) do |icon_class|
  first(".fa.fa-#{icon_class}").click
end

Then(/^I see "([^"]*)" in the "([^"]*)"$/) do |text, container|
  within container do
    expect(page).to have_content text
  end
end

Then(/^the page meta name "([^"]*)" includes "([^"]*)"$/) do |tag, content|
  entry = find "head meta[name=#{tag}]", visible: false
  expect(entry['content']).to include content
end

Then(/^the page meta property "([^"]*)" includes "([^"]*)"$/) do |tag, content|
  entry = find "head meta[property='#{tag}']", visible: false
  expect(entry['content']).to include content
end

Then(/^I can get to the about page from the footer$/) do
  within '.sidenav__footer .fine-print-links' do
    click_on 'about'
    expect(current_path).to eq '/about'
    page.go_back
  end
end

Then(/^I can get to the privacy page from the footer$/) do
  within '.sidenav__footer .fine-print-links' do
    click_on 'privacy'
    expect(current_path).to eq '/privacy'
    page.go_back
  end
end

Then(/^I can get to the contact page from the footer$/) do
  within '.sidenav__footer .fine-print-links' do
    click_on 'contact'
    expect(current_path).to eq '/contact'
    page.go_back
  end
end

Then(/^I can send feedback via the footer link$/) do
  within '.sidenav__footer .fine-print-links' do
    click_on 'feedback'
  end
  step %(I fill out and submit the feedback form)
end

Then(/^I can see the credits from the footer link$/) do
  within '.sidenav__footer .fine-print-links' do
    click_on 'credits'
  end
  expect(page).to have_content 'Built at MAU Headquarters'
  click_on 'close'
  expect(page).not_to have_content 'Built at MAU Headquarters'
end

When(/^I fill out and submit the feedback form$/) do
  within '#feedback' do
    fill_in 'Email', with: 'whomever@example.com'
    fill_in 'Comment', with: 'This site rules!'
    click_on 'Send'
  end
end

When(/^I refresh the page$/) do
  visit current_path
end

When(/^I go to the new tab$/) do
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
end
