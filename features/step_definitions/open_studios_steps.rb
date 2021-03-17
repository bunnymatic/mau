When /I click on the current open studios link/ do
  os_link_text = OpenStudiosEventService.current.for_display(reverse: true)
  click_on_first os_link_text
end

Then('I see the unregistration dialog') do
  within('.ReactModal__Content') do
    expect(page).to have_content 'You will no longer be registered for Open Studios'
    expect(page).to have_content('Yes')
    expect(page).to have_content('No')
  end
end

Then('I see the registration dialog') do
  within('.ReactModal__Content') do
    expect(page).to have_content 'This will register you as a participating artist for Open Studios'
    expect(page).to have_content('Yes')
    expect(page).to have_content('No')
  end
end

Then('I see the registration message') do
  expect(page).not_to have_css('.ReactModal__Content')
  expect(page).to have_content('Will you be participating in Open Studios on')
  expect(page).to have_button('Yes - Register Me')
end

Then('I see the open studios info form') do
  expect(page).to have_content(
    OpenStudiosEventPresenter.new(OpenStudiosEventService.current).special_event_date_range,
  )
  expect(page).to have_css('input[name=shopUrl]')
  expect(page).to have_css('input[name=showEmail]')
  expect(page).to have_button('Un-Register Me')
end

Then(/^I see the open studios cms content/) do
  markdown = page.all('.section.markdown')
  within markdown[0] do
    expect(page).to have_selector 'h1', text: 'this is an h1'
    expect(page).to have_selector 'h2', text: 'this is an h2'
    expect(page).to have_selector 'p'
  end
  within markdown[1] do
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
  expect(page).to have_selector '.react-component[data-section="preview_reception"]'
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
  expect(page).to have_selector '#open_studios_event_start_date'
  expect(page).to have_selector '#open_studios_event_end_date'
end

def set_start_end_date_on_open_studios_form(start_date, end_date)
  fill_in 'Start date', with: start_date
  fill_in 'End date', with: end_date
end

Then /I change the date to next month and the title to "(.*)"/ do |title|
  @start_date = Time.zone.now + 1.month
  @end_date = @start_date + 1.day
  set_start_end_date_on_open_studios_form(@start_date, @end_date)
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
  visit "http://openstudios.lvh.me#{artist_open_studio_path(@artist)}"
end

Then('I see that artist\'s open studios pieces') do
  expect(page).to have_content(@artist.name)
  expect(@artist.art_pieces).to have_at_least(1).art_piece
  expect(page).to have_css('.art-piece', count: @artist.art_pieces.count)
end

When('I hover over a cms section') do
  page.all('.section.markdown.editable').first.hover
end

When('I select every other time slot for the video conference schedule') do
  within '.special-event-schedule' do
    page.all("[type='checkbox']").each_slice(2) do |cb|
      cb[0].click
    end
  end
end

When('I see every other time slot for the video conference schedule has been checked') do
  within '.special-event-schedule' do
    page.all("[type='checkbox']").each_slice(2) do |cb|
      expect(cb[0].checked?).to eq true
      expect(cb[1].checked?).to eq false
    end
  end
end
