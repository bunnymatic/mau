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
