# frozen_string_literal: true

When /I click on the current open studios link/ do
  os_link_text = OpenStudiosEventService.current.for_display(true)
  click_on_first os_link_text
end

When /^I check yep for doing open studios$/ do
  el = find('#events .toggle-button .toggle-button__label_on')
  begin
    el.trigger('click')
  rescue Capybara::NotSupportedByDriverError
    el.click
  end
end

When /^I check nope for doing open studios$/ do
  el = find('#events .toggle-button .toggle-button__label_off')
  begin
    el.trigger('click')
  rescue Capybara::NotSupportedByDriverError
    el.click
  end
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

When /I click on the open studios page "([^"]*)" tab/ do |tab|
  within '.open-studios-content-tabs' do
    click_on tab
  end
end

Then /I see the open studios page$/ do
  expect(page).to have_selector 'h2', text: /Open Studios/
  tabs = page.all('.open-studios-content-tabs a[data-toggle="tab"]').map(&:text)
  expect(tabs).to match_array %w[about participants map]
  expect(current_path).to eq open_studios_path
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

def set_start_end_date_on_open_studios_form(_start_date, _end_date)
  page.execute_script("$('#open_studios_event_start_date').val('#{@start_date.to_date}');")
  page.execute_script("$('#open_studios_event_end_date').val('#{@end_date.to_date}');")
  page.execute_script("$('#open_studios_event_start_date').trigger('change');")
end

Then /I change the date to next month and the title to \"(.*)\"/ do |title|
  @start_date = Time.zone.now + 1.month
  @end_date = @start_date + 1.day
  set_start_end_date_on_open_studios_form(@start_date, @end_date)
  # fill_in "Start date", with: @start_date.to_date
  # fill_in "End date", with: @end_date.to_date
  fill_in 'Key', with: @start_date.strftime('%Y%m')
  fill_in 'Title', with: title
  click_on 'Update'
end

Then /I see the open studios event with the title \"(.*)\"$/ do |title|
  within table_row_matching(title) do
    expect(page).to have_content @start_date.strftime('%Y%m')
  end
end

When(/^I click delete on the "([^"]*)" titled open studios event$/) do |title|
  within table_row_matching(title) do
    click_on 'Delete'
  end
end

Then /^I fill in the open studios event form for next weekend with the title \"(.*)\"$/ do |title|
  dt = Time.zone.now.beginning_of_week + 11.days
  @os_title = 'Fall OS'
  @start_date = dt
  @end_date = dt + 2.days
  fill_in 'Title', with: title
  set_start_end_date_on_open_studios_form(@start_date, @end_date)

  expect(find('#open_studios_event_key').value).to eql @start_date.strftime('%Y%m')
  attach_file 'Logo', Rails.root.join('spec', 'fixtures', 'files', 'open_studios_event.png')
  click_on 'Create'
end

Then /^I see that the open studios event titled \"(.*)\" is no longer there$/ do |title|
  within('.os-events tbody') do
    expect(page).not_to have_content(title)
  end
end

Then(/^I see the open studios participants$/) do
  cards = all('.artist-card')
  expect(cards.count).to be_positive
  expect(cards.count).to eql all('.os-violator').count
end

Then(/^I see a map of open studios participants$/) do
  expect(page).to have_css '#map-canvas'
end

Then(/^I see only artist cards from artists that are doing open studios$/) do
  expect(page).to have_css '.artist-card .os-violator'
end

Then(/^I see a list of artists doing open studios with their studio addresses$/) do
  expect(page).to have_css '.map__list-of-artists .tenants'
end
