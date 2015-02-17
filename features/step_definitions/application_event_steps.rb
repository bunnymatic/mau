Then(/^I see all application events sections/) do
  expect(page).to have_selector('.generic_events tr', count: 1)
  expect(page).to have_selector('.open_studios_signup_events tr', count: 1)
end
