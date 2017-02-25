# frozen_string_literal: true
def get_email_directive_selector(type)
  list = EmailList.where(type: type + 'MailerList').first
  "email-list-manager[list-id=\"#{list.id}\"]"
end

def get_email_directive(type)
  page.find(get_email_directive_selector(type))
end

When /^I fill in the "(.*?)" email form with:$/ do |list_name, table|
  within get_email_directive_selector(list_name) do
    info = table.hashes.first
    info.each do |field, val|
      fill_in_field_with_value field, val
    end
  end
end

Then(/^I can see the "(.*?)" email list$/) do |list_name|
  expect(page).to have_css get_email_directive_selector(list_name)
end

When(/^I click to add an email to the "(.*?)" list$/) do |list_name|
  within get_email_directive(list_name) do
    click_on 'add an email to this list'
  end
end

Then(/^I see that "(.*?)" is on the "(.*?)" email list$/) do |email_string, list_name|
  wait_until do
    within get_email_directive(list_name) do
      page.has_content? email_string
    end
  end
  expect(page).to have_content email_string
end

When /I click "(.*?)" in the "(.*?)" email form$/ do |button, list_name|
  within get_email_directive(list_name) do
    click_on button
  end
end

Then(/^I click to remove "([^"]*)" from the "(.*?)" list$/) do |email, list_name|
  within get_email_directive(list_name) do
    link_title = "remove #{email} from the list"
    all('.del-btn a').select { |t| t['title'] == link_title }.first.click
  end
end

Then(/^I see that "([^"]*)" is not on the "([^"]*)" email list$/) do |email, list_name|
  within get_email_directive(list_name) do
    expect(page).to_not have_content(email)
  end
end
