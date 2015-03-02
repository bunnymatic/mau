require_relative '../../spec/support/mobile_setup'

def path_from_title(titleized_path_name)
  clean_path_name = titleized_path_name.downcase.gsub(/ /, '_')
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
  all('a').select{|a| a["title"] == title } ||
    all('button').select{|b| b.value == title }
end

def find_links_or_buttons(locator)
  result = all("##{locator}") if /^-_[A-z][0-9]*$/ =~ locator
  return result unless result.blank?
  result = all('a,button', text: locator)
  return result unless result.blank?
  all_links_or_buttons_with_title(locator)
end

Given /^the cache is clear$/ do
  Rails.cache.clear
end

Given /^Mailchimp is hooked up$/ do
  stub_mailchimp
end

When /I'm on my smart phone/ do
  page.driver.headers = {"User-Agent" => IPHONE_USER_AGENT}
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^I (save|take) a screenshot$/ do |dummy|
  f = File.expand_path("./tmp/capybara-screenshot-#{Time.now.to_f}.png")
  save_screenshot(f)
  puts "Saved Screenshot #{f}"
end

When /I visit the login page/ do
  visit login_path
end

When /I visit the signup page/ do
  visit signup_path
end

When /I visit the fan signup page/ do
  visit signup_path(type: 'MAUFan')
end

When /I sign in with password "(.*?)"/ do |pass|
  step "I visit the login page"
  fill_in_login_form @artist.login, pass
  click_on "Sign In"
end
  
When /I am signed in as an artist/ do
  steps %Q{
    Given an account has been created
    Given I visit the login page
    When I fill in valid credentials
    And I click "Sign In"
  }
end

When /^I (log|sign)\s?out$/ do |dummy|
  within '.nav' do
    click_on 'sign out'
  end                        
end

Then /^I see that I'm signed in$/ do
  within '.nav' do
    expect(page).to have_link "my mau"
  end
end

When(/^I change "(.*?)" to "(.*?)" in the "(.*?)" form$/) do |form_field_label, value, form_selector|
  within form_selector do
    fill_in form_field_label, with: value, fill_options: { exact: true }
  end
end

When(/^I change "(.*?)" to "(.*?)"$/) do |form_field_label, value|
  fill_in form_field_label, with: value, fill_options: { exact: true }
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
  within 'form' do
    expect(page).to have_selector '.error', text: msg
  end
end

Then(/^I do not see an error message$/) do
  expect(page).to_not have_selector '.error-msg, .flash__error, .err'
end

Then(/^I see an error message "(.*?)"$/) do |msg|
  expect(page).to have_selector '.error-msg', text: msg
end

Then(/^I see a flash error "(.*?)"$/) do |msg|
  expect(page).to have_selector '.flash.flash__error', text: msg
end

Then(/^I see a flash notice "(.*?)"$/) do |msg|
  expect(page).to have_selector '.flash.flash__notice', text: msg
end

Then(/^I close the notice$/) do
  find('.flash.flash__notice .flash__close').click
end

Then(/^I close the flash$/) do
  all('.flash .js-flash__close').each {|f| f.click}
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

When(/^I click (on\s+)?"([^"]*)"$/) do |dummy, link_text|
  click_on link_text
end

When(/^I click on "(.*?)" in the "(.*?)"$/) do |link, container|
  within container do
    click_on_first link
  end
end

When(/^I click on "(.*?)" in the admin menu$/) do |link_title|
  step %Q|I click on "#{link_title}" in the "#admin_nav"|
end

When(/^I click on "(.*?)" in the sidebar menu$/) do |link_title|
  step %Q|I click on "#{link_title}" in the ".nav.nav-tabs"|
end

When(/^I click on the first "([^"]*?)" (button|link)$/) do |button_text, dummy|
  find_first_link_or_button(button_text).click
end

When(/^I click on the last "([^"]*?)" (button|link)$/) do |button_text, dummy|
  find_last_link_or_button(button_text).click
end

Then(/^I see a message "(.*?)"$/) do |message|
  expect(page).to have_selector '.flash', text: message
end

def fill_in_field_with_value(field, value)
  # First try with a label
  xpath = "//label[normalize-space(translate(.,'*',''))='#{field}' or @for='#{field}']/.."
  if page.all(:xpath, xpath).empty?
    # Then try with a input field
    xpath = "//input[@type='text' and (@id='#{field}' or @name='#{field}')]/.."
  end
  
  within(:xpath, xpath) do
    fill_in(field, with: value)
  end
end

When(/^I fill in the form with:$/) do |table|
  info = table.hashes.first
  info.each do |field, val|
    if /Studio/ =~ field
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
      if /Studio/ =~ field
        select val, from: field
      else
        fill_in_field_with_value field, val
      end
    end
  end
end

When(/^I choose "([^"]*?)" from "(.*?)"$/) do |option, select|
  select option, from: select
end

When /^I choose "([^"]*?)"$/ do |radio|
  choose radio
end
