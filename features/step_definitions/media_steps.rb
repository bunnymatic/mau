Then(/^I see the admin media list$/) do
  expect(page).to have_current_path admin_media_path
end

Then(/^I see the "(.*?)" as a medium$/) do |arg1|
  expect(page).to have_selector('#mediums_index td.name', text: arg1)
end

When(/^I click on the first medium$/) do
  wait_until { page.find('a.medium-link') }

  name = page.find('a.medium-link').text
  @medium = Medium.find_by(name:)
  within '.art-piece__info' do
    click_on name
  end
end

Then(/^I see that medium detail page$/) do
  expect(page).to have_css('.media.show')
  expect(page).to have_css '.header', text: @medium.name
  expect(page).to have_css '.tagcloud li'
  expect(page).to have_css '.art-card'
  expect(page).to have_current_path medium_path(@medium)
end
