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
