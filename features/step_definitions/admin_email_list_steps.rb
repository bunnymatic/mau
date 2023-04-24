def get_email_list_manager(type)
  page.all('.email-list-manager__wrapper').detect do |wrapper|
    wrapper.find('h4', text: type)
  rescue Capybara::ElementNotFound # rubocop:disable Lint/SuppressedException
  end
end

When /^I fill in the "(.*?)" email form with:$/ do |_list_name, table|
  within '.ReactModal__Content' do
    info = table.hashes.first
    info.each do |field, val|
      fill_in field, with: val # _field_with_value field, val
    end
  end
end

Then(/^I can see the "(.*?)" email list$/) do |list_name|
  expect(get_email_list_manager(list_name)).to be_present
end

When(/^I click to add an email to the "(.*?)" list$/) do |list_name|
  within get_email_list_manager(list_name) do
    click_on 'add an email to this list'
  end
end

Then(/^I see that "(.*?)" is on the "(.*?)" email list$/) do |email_string, list_name|
  wait_until do
    within get_email_list_manager(list_name) do
      page.has_content? email_string
    end
  end
  expect(page_body).to have_content email_string
end

When /I click "(.*?)" in the "(.*?)" email form$/ do |button, _list_name|
  within '.ReactModal__Content' do
    click_on button
  end
end

Then(/^I click to remove "([^"]*)" from the "(.*?)" list$/) do |email, list_name|
  within get_email_list_manager(list_name) do
    link_title = "remove #{email} from the list"
    click_on link_title
  end
end

Then(/^I see that "([^"]*)" is not on the "([^"]*)" email list$/) do |email, list_name|
  within get_email_list_manager(list_name) do
    expect(page_body).to_not have_content(email)
  end
end
