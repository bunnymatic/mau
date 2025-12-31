Then(/^I see some of the art that's in the system$/) do
  expect(page).to have_selector('#sampler .sampler__thumb')
end

Then('I see the default banner') do
  expect(page).to have_selector('.sampler__promo', text: 'MISSION ARTISTS')
end

Then('I see the default open studios banner') do
  expect(page).to have_selector('.sampler__promo', text: @open_studios_event.title.upcase)
  expect(page).to have_selector('.sampler__promo', text: @open_studios_event.for_display(month_first: true).upcase)
end

Then('I see the custom open studios banner') do
  os = OpenStudiosEventService.current
  expect(page).to have_selector('.sampler__promo')
  image = find('.sampler_promo--os-banner-image')
  expect(image['style']).to match /background-image:\s+url/
  link_wrapper = image.find(:xpath, '..')
  expect(link_wrapper['href']).to end_with '/open_studios'
  expect(link_wrapper['title']).to eq "#{os.title} #{os.for_display(month_first: true)}"
end
