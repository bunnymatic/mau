# frozen_string_literal: true
When /I click on the current open studios link/ do
  os_link_text = OpenStudiosEventService.current.for_display(true)
  click_on_first os_link_text
end

When /^I check yep for doing open studios$/ do
  find('#events .toggle-button .toggle-button__label_on').trigger('click')
end

When /^I check nope for doing open studios$/ do
  find('#events .toggle-button .toggle-button__label_off').trigger('click')
end

Then(/^I see the open studios cms content/) do
  within '.section.markdown[data-section=summary]' do
    expect(page).to have_selector 'h1', text: 'this is an h1'
    expect(page).to have_selector 'h2', text: 'this is an h2'
    expect(page).to have_selector 'p'
  end
  within '.section.markdown[data-section=preview_reception]' do
    expect(page).to have_selector 'h1', text: 'this is an h1'
    expect(page).to have_selector 'h2', text: 'this is an h2'
    expect(page).to have_selector 'p'
  end
end

Then(/^I see the open studios content is not editable/) do
  expect(page).to_not have_selector '.open_studios .section.markdown.editable'
end

Then(/^I see the open studios content is editable/) do
  expect(page).to have_selector '.open_studios .section.markdown.editable'
end

Then /I see the open studios page$/ do
  expect(current_path).to eq open_studios_path
  expect(page).to have_selector 'h2', text: /Open Studios/
end

Then(/^I see the open studios events$/) do
  expect(page).to have_selector 'table.os-events tbody tr', count: OpenStudiosEvent.count
  expect(page).to have_selector 'table.os-events tbody tr td.key', text: OpenStudiosEvent.all.first.key
end

Then /^I see a new open studios form$/ do
  expect(page).to have_selector 'form'
  expect(page).to have_selector '#open_studios_event_start_date.js-datepicker'
  expect(page).to have_selector '#open_studios_event_end_date.js-datepicker'
end

Then /I change the date to next month/ do
  @start_date = Time.zone.now + 1.month
  @end_date = @start_date + 1.day

  fill_in 'Start date', with: @start_date
  fill_in 'End date', with: @end_date
  fill_in 'Key', with: @start_date.strftime('%Y%m')
  click_on 'Update'
end

Then /I see the updated open studios event/ do
  @os_event = OpenStudiosEvent.where(key: @start_date.strftime('%Y%m')).first
  expect(@os_event).to be_present
  expect(@os_event.end_date.to_i).to eql @end_date.to_i
  expect(@os_event.key).to eql @start_date.strftime('%Y%m')
end

Then /^I fill in the open studios event form for next weekend without a key$/ do
  @start_date = Time.zone.now.beginning_of_week + 11.days
  @end_date = Time.zone.now.beginning_of_week + 11.days
  fill_in 'Start date', with: @start_date
  fill_in 'End date', with: @end_date
  attach_file 'Logo', Rails.root.join('spec', 'fixtures', 'files', 'open_studios_event.png')
  click_on 'Create'
end

Then /^I fill in the open studios event form for next weekend$/ do
  dt = Time.zone.now.beginning_of_week + 11.days
  @os_title = 'Fall OS'
  @start_date = dt
  @end_date = dt + 2.days
  fill_in 'Title', with: @os_title
  fill_in 'Start date', with: @start_date
  fill_in 'End date', with: @end_date
  fill_in 'Key', with: dt.strftime('%Y%m')
  attach_file 'Logo', Rails.root.join('spec', 'fixtures', 'files', 'open_studios_event.png')
  click_on 'Create'
end

Then /^I see a new open studios event$/ do
  @os_event = OpenStudiosEvent.where(key: @start_date.strftime('%Y%m')).first
  expect(@os_event).to be_present
  expect(@os_event.end_date.to_i).to eql @end_date.to_i
  expect(@os_event.key).to eql @start_date.strftime('%Y%m')
  expect(@os_event.title).to eql @os_title
end

Then /^I see that the new open studios event is no longer there$/ do
  expect(page).to have_selector('td', text: @os_event.key)
end

Then(/^I see the open studios participants$/) do
  cards = all('.artist-card')
  expect(cards.count).to be_positive
  expect(cards.count).to eql all('.os-violator').count
end

Then(/^I see a map of open studios participants$/) do
  expect(page).to have_css '#map-canvas'
end
