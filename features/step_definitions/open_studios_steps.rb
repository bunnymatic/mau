When /I click on the current open studios link/ do
  os_link_text = OpenStudiosEventService.current.for_display(reverse: true)
  click_on_first os_link_text
end

Then('I see the registration dialog') do
  expect(page).to have_css('.ReactModal__Content')
  expect(page).to have_content('You are registering to participate as an Open Studios artist')
  expect(page).to have_content('I have questions')
end

Then('I see the registration message') do
  expect(page).not_to have_css('.ReactModal__Content')
  expect(page).to have_content('Will you be participating in Open Studios on')
  expect(page).to have_button('Yes - Register Me')
end

Then('I see the open studios info form') do
  expect(page).to have_css('input[name=shopUrl]')
  expect(page).to have_css('input[name=showEmail]')
  expect(page).to have_button('Nope - not this time')
end

Then(/^I see the open studios cms content/) do
  within '.section.markdown[data-section="summary"]' do
    expect(page).to have_selector 'h1', text: 'this is an h1'
    expect(page).to have_selector 'h2', text: 'this is an h2'
    expect(page).to have_selector 'p'
  end
  within '.section.markdown[data-section="preview_reception"]' do
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

Then /I see the open studios promo page$/ do
  expect(page).to have_selector 'h2', text: /Open Studios/
  expect(page).to have_content /participating artists/i
  expect(current_path).to eq open_studios_path
end

Then(/^I see the open studios events$/) do
  expect(page).to have_selector '.os-events__table-row', count: OpenStudiosEvent.count
  expect(page).to have_selector '.os-events__table-item--key', text: OpenStudiosEvent.all.first.key
end

Then /^I see a new open studios form$/ do
  expect(page).to have_selector 'form'
  expect(page).to have_selector '#open_studios_event_start_date.js-datepicker'
  expect(page).to have_selector '#open_studios_event_end_date.js-datepicker'
end

def set_pickadate_date(pickadate_selector, date)
  page.execute_script("$('#{pickadate_selector}').pickadate('picker').set('select', [#{date.year}, #{date.month - 1}, #{date.day}]);")
end

def set_start_end_date_on_open_studios_form(start_date, end_date)
  set_pickadate_date('#open_studios_event_start_date', start_date)
  set_pickadate_date('#open_studios_event_end_date', end_date)
end

Then /I change the date to next month and the title to "(.*)"/ do |title|
  @start_date = Time.zone.now + 1.month
  @end_date = @start_date + 1.day
  set_start_end_date_on_open_studios_form(@start_date, @end_date)
  # fill_in "Start date", with: @start_date.to_date
  # fill_in "End date", with: @end_date.to_date
  fill_in 'Key', with: @start_date.strftime('%Y%m')
  fill_in 'Title', with: title
  click_on 'Update'
end

Then /I see the open studios event with the title "(.*)"$/ do |title|
  within table_row_matching(title) do
    expect(page).to have_content @start_date.strftime('%Y%m')
  end
end

When(/^I click delete on the "([^"]*)" titled open studios event$/) do |title|
  within table_row_matching(title) do
    click_on 'Delete'
  end
  step %(I close the flash)
end

Then /^I fill in the open studios event form for next weekend with the title "(.*)"$/ do |title|
  dt = Time.zone.now.beginning_of_month.next_month + 2.days
  @os_title = 'Fall OS'
  @start_date = dt
  @end_date = dt + 2.days
  fill_in 'Title', with: title
  set_start_end_date_on_open_studios_form(@start_date, @end_date)
  fill_in 'Start time', with: '12a'
  fill_in 'End time', with: '5a'
  expect(find('#open_studios_event_key').value).to eql @start_date.strftime('%Y%m')
  click_on 'Create'
end

Then /^I see that the open studios event titled "(.*)" is no longer there$/ do |title|
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

# os status page
Then(/^I see stars for all open studios participants$/) do
  participants = OpenStudiosParticipant.count
  expect(page).to have_css('.fa.fa-star', count: participants)
end

When('I visit the first artist\'s open studios page') do
  @artist = Artist.active.joins(:open_studios_events).first
  visit artist_open_studios_path(@artist)
end

Then('I see that artist\'s open studios pieces') do
  expect(page).to have_content(@artist.name)
  expect(@artist.art_pieces).to have_at_least(1).art_piece
  expect(page).to have_css('.art-piece', count: @artist.art_pieces.count)
end

When('I hover over a cms section') do
  page.all('.section.markdown.editable').first.hover
end
