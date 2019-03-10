# frozen_string_literal: true

When(/^I fill in the new studio information for "(.*)"$/) do |name|
  within '#new_studio' do
    fill_in 'Name', with: name
    fill_in 'Street', with: '100 Market St'
    attach_file 'Photo', fixture_file('files/art.png')
  end
end

Then(/^I see there is a new studio called "(.*)"$/) do |name|
  expect(page).to have_flash :notice, 'More studios means more artists'
  expect(page).to have_content name
end

Then(/^I click on the last remove studio button$/) do
  @studio = Studio.last
  within table_row_matching(@studio.name) do
    click_on 'Remove'
  end
end

Then(/^I see the last studio has been removed$/) do
  expect(page).to have_flash :notice, 'Sad to see them go'
end

When("I update the studio's latitude and longitude to {string} and {string}") do |lat, lng|
  fill_in 'Latitude', with: lat
  fill_in 'Longitude', with: lng
  click_on 'Update'
end

Then('I can tell the db knows the studio the latitude and longitude set to {string} and {string}') do |lat, lng|
  studio = Studio.by_position.first
  expect(studio.lat.to_s).to eq lat
  expect(studio.lng.to_s).to eq lng
end
