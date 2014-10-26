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
  expect(page).to have_selector 'table tbody tr', :count => @open_studios_events.length
  expect(page).to have_selector 'table tbody tr td.key', :text => @open_studios_events.first.key
end

Then /^I see a new open studios form$/ do
  expect(page).to have_selector 'form'
  expect(page).to have_selector '#open_studios_event_start_date.js-datepicker'
  expect(page).to have_selector '#open_studios_event_end_date.js-datepicker'
end

Then /^I fill in the open studios event form for next weekend without a key$/ do
  @start_date = Time.zone.now.beginning_of_week + 11.days
  @end_date = Time.zone.now.beginning_of_week + 11.days
  fill_in "Start date", with: @start_date
  fill_in "End date", with: @end_date
  click_on "Create"
end

Then /^I fill in the open studios event form for next weekend$/ do
  dt = Time.zone.now.beginning_of_week + 11.days
  @start_date = dt
  @end_date = dt + 2.days
  fill_in "Start date", with: @start_date
  fill_in "End date", with: @end_date
  fill_in "Key", with: dt.strftime("%Y%m")
  click_on "Create"
end

Then /^I see a new open studios event$/ do
  @os_event = OpenStudiosEvent.where(start_date: @start_date).first
  expect(@os_event).to be_present
  expect(@os_event.end_date).to eql @end_date
  expect(@os_event.key).to eql @start_date.strftime("%Y%m")
end

Then /^I see that the new open studios event is no longer there$/ do
  expect(page).to have_selector('td', text: @os_event.key)
end
