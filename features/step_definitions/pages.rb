# frozen_string_literal: true
When /^I visit the home page$/ do
  visit '/'
end

When /^I visit the about page$/ do
  visit '/about'
end

Then /^I see the mobile about page$/ do
  expect(page).to have_content "What is Open Studios"
  expect(page).to have_link OpenStudiosEventService.current.for_display, href: '/open_studios'
end

