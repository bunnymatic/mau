Then(/^I should see the open studios cms content/) do
  expect(page).to have_selector '.section.markdown[data-section=summary]'
  expect(page).to have_selector '.section.markdown[data-section=preview_reception]'
end

Then(/^I should see the open studios content is not editable/) do
  expect(page).to_not have_selector '#open_studios .section.markdown.editable'
end

Then(/^I should see the open studios content is editable/) do
  expect(page).to have_selector '#open_studios .section.markdown.editable'
end

Then(/^I see the open studios events$/) do
  save_and_open_page
  expect(page).to have_selector 'table tbody tr', :count => @open_studios_events.length
  expect(page).to have_selector 'table tbody tr td.key', :text => @open_studios_events.first.key
end
