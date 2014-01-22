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

Then(/^I see an error message "(.*?)"$/) do |msg|
  expect(page).to have_content msg
end

Then(/^I see an flash notice "(.*?)"$/) do |msg|
  expect(page).to have_selector '.notice', :text => msg
end

When(/^I visit the "(.*?)" page$/) do |titleized_path_name|
  visit path_from_title(titleized_path_name)
end

Then(/^I see the "(.*?)" page$/) do |titleized_path_name|
  expect(current_path).to eql path_from_title(titleized_path_name)
end
