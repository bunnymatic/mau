Then(/^I see some of the art that's in the system$/) do
  expect(page).to have_selector('#sampler .sampler__thumb')
end

Then('I see the default banner') do
  expect(page).to have_selector('.sampler__promo', text: 'mission artists')
end

Then('I see the default open studios banner') do
  expect(page).to have_selector('.sampler__promo', text: @open_studios_event.title.upcase)
  expect(page).to have_selector('.sampler__promo', text: @open_studios_event.for_display(month_first: true).upcase)
end

Then('I see the custom open studios banner') do
  ActiveStorage::Current.host = 'http://example.com'
  expect(page).to have_selector('.sampler__promo', text: @open_studios_event.for_display(month_first: true))
end
