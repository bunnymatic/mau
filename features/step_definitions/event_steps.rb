# frozen_string_literal: true
Then(/^I see a list of events/) do
  expect(page).to have_selector '.events .event .title'
end

Then(/^I see a list of months and years for existing events/) do
  expect(page).to have_selector 'nav.event_nav'
  keys = @events.map { |ev| ev.stime.strftime('%B %Y') }
  keys.each do |k|
    expect(page).to have_selector '.by_month a', k
  end
end

Then(/^I click on the calendar link$/) do
  all('a', text: 'View Events Calendar').first.click
end

Then(/^I see the events for that month$/) do
  key = @events.first.stime.strftime('%Y%m')
  expected_events = Event.published.select { |ev| ev.stime.strftime('%Y%m') == key }
  expect(expected_events).to have_at_least(1).event
  expected_events.each do |ev|
    expect(page).to have_selector('.title', text: ev.title)
  end
end

When(/^I click on the first month link/) do
  link_text = @published_events.first.stime.strftime('%B %Y')
  click_link(link_text)
end

Then(/^I see a feed of events/) do
  published_events = @events.select { |e| e.published_at.present? }

  expect(page).to have_selector 'entry content', count: published_events.count
  expect(page).to have_selector 'entry id', count: published_events.count
  expect(page).to have_content published_events.first.title
end
