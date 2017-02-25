# frozen_string_literal: true
Then(/^I see the admin media list$/) do
  expect(current_path).to eql admin_media_path
end

When(/^I fill in "(.*?)" for "(.*?)"$/) do |arg1, arg2|
  fill_in arg2, with: arg1
end

Then(/^I see the "(.*?)" as a medium$/) do |arg1|
  expect(page).to have_selector('#mediums_index td.name', text: arg1)
end

When(/^I click on the first medium$/) do
  wait_until { page.find("medium a") }
  medium_link = all('.art-piece__info .media a').first
  medium_path = medium_link['href']
  @medium = Medium.find( medium_path.split("/").last )
  medium_link.click
end

Then(/^I see that medium detail page$/) do
  expect(current_path).to eql medium_path(@medium)
  expect(page).to have_css '.header', text: @medium.name
  expect(page).to have_css '.tagcloud li'
  expect(page).to have_css ".art-card"
end
