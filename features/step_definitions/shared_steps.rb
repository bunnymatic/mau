def path_from_title(titleized_path_name)
  clean_path_name = titleized_path_name.downcase.gsub(/ /, '_')
  path_helper_name = "#{clean_path_name}_path".to_sym
  send(path_helper_name)
end

Then /^show me the page$/ do
  save_and_open_page
end

When /I visit the login page/ do
  visit '/login'
end

Then(/^I do not see an error message$/) do
  expect(page).to_not have_selector '.error-msg'
end

Then(/^I see an error message "(.*?)"$/) do |msg|
  expect(page).to have_selector '.error-msg', :text => msg
end

Then(/^I see an flash notice "(.*?)"$/) do |msg|
  expect(page).to have_selector '.notice', :text => msg
end

Then(/^I close the notice$/) do
  find('.notice .close-btn').click()
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
  within('.tbl-content') do
    all('a,button', :text => button_text).first.click
  end
end

When(/^I click on the last "([^"]*?)" button$/) do |button_text|
  within('.tbl-content') do
    all('a,button', :text => button_text).last.click
  end
end

Then(/^I see a message "(.*?)"$/) do |message|
  expect(page).to have_selector '.flash', :text => message
end
