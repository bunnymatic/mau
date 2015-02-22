When /I click on the current open studios link/ do
  os_link_text = OpenStudiosEvent.current.for_display(true)
  click_on_first os_link_text
end

Then(/^I see the open studios cms content/) do
  expect(page).to have_selector '.section.markdown[data-section=summary]'
  expect(page).to have_selector '.section.markdown[data-section=preview_reception]'
end

Then(/^I see the open studios cms mobile content/) do
  expect(page).to have_selector '.section .markdown'
end


Then(/^I see the open studios content is not editable/) do
  expect(page).to_not have_selector '#open_studios .section.markdown.editable'
end

Then(/^I see the open studios content is editable/) do
  expect(page).to have_selector '#open_studios .section.markdown.editable'
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

  fill_in "Start date", with: @start_date
  fill_in "End date", with: @end_date
  fill_in "Key", with: @start_date.strftime("%Y%m")
  click_on "Update"
end

Then /I see the updated open studios event/ do
  @os_event = OpenStudiosEvent.where(key: @start_date.strftime("%Y%m")).first
  expect(@os_event).to be_present
  expect(@os_event.end_date.to_i).to eql @end_date.to_i
  expect(@os_event.key).to eql @start_date.strftime("%Y%m")
end

Then /^I fill in the open studios event form for next weekend without a key$/ do
  @start_date = Time.zone.now.beginning_of_week + 11.days
  @end_date = Time.zone.now.beginning_of_week + 11.days
  fill_in "Start date", with: @start_date
  fill_in "End date", with: @end_date
  attach_file "Logo", File.join(Rails.root,'spec/fixtures/open_studios_event.png')
  click_on "Create"
end

Then /^I fill in the open studios event form for next weekend$/ do
  dt = Time.zone.now.beginning_of_week + 11.days
  @os_title = "Fall OS"
  @start_date = dt
  @end_date = dt + 2.days
  fill_in "Title", with: @os_title
  fill_in "Start date", with: @start_date
  fill_in "End date", with: @end_date
  fill_in "Key", with: dt.strftime("%Y%m")
  attach_file "Logo", File.join(Rails.root,'spec/fixtures/open_studios_event.png')
  click_on "Create"
end

Then /^I see a new open studios event$/ do
  @os_event = OpenStudiosEvent.where(key: @start_date.strftime("%Y%m")).first
  expect(@os_event).to be_present
  expect(@os_event.end_date.to_i).to eql @end_date.to_i
  expect(@os_event.key).to eql @start_date.strftime("%Y%m")
  expect(@os_event.title).to eql @os_title
end

Then /^I see that the new open studios event is no longer there$/ do
  expect(page).to have_selector('td', text: @os_event.key)
end
