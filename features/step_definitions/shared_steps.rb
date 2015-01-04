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

When /^I (logout|sign out)$/ do |dummy|
  within '.signin-nav' do
    click_on 'sign out'
  end                        
end

Then /^I see that I'm signed in$/ do
  within '.signin-nav' do
    expect(page).to have_link @artist.login, href: user_path(@artist)
  end
end

When(/^I change "(.*?)" to "(.*?)"/) do |form_field_label, value|
  within 'form.formtastic' do
    fill_in form_field_label, with: value, fill_options: { exact: true }
  end
end

Then(/my "(.*?)" is "(.*?)" in the "(.*?)" section of the form/) do |form_field_label, value, section|
  step "I click on \"#{section}\""
  expect(page).to have_selector 'form.formtastic'
  within 'form.formtastic' do
    expect(find_field(form_field_label).value).to eql value
  end
end


Then(/^I do not see an error message$/) do
  expect(page).to_not have_selector '.error-msg'
end

Then(/^I see an error message "(.*?)"$/) do |msg|
  expect(page).to have_selector '.error-msg, .error', text: msg
end

Then(/^I see a flash notice "(.*?)"$/) do |msg|
  expect(page).to have_selector '.notice', text: msg
end

Then(/^I close the notice$/) do
  find('.notice .close-btn').trigger('click')
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

When(/^I click on "(.*?)" in the admin menu$/) do |link_title|
  within('#admin_nav') do
    click_on(link_title)
  end
end

When(/^I click on "(.*?)" in the sidebar menu$/) do |link_title|
  within('#sidebar_nav') do
    click_on(link_title)
  end
end

When(/^I click on the first "([^"]*?)" (button|link)$/) do |button_text, dummy|
  within('.singlecolumn, .tbl-content') do
    find_first_link_or_button(button_text).click
  end
end

When(/^I click on the last "([^"]*?)" (button|link)$/) do |button_text, dummy|
  within('.singlecolumn, .tbl-content') do
    find_last_link_or_button(button_text).click
  end
end

Then(/^I see a message "(.*?)"$/) do |message|
  expect(page).to have_selector '.flash', text: message
end

When(/^I fill in the form with:$/) do |table|
  info = table.hashes.first
  info.each do |field, val|
    fill_in field, with: val
  end
end
