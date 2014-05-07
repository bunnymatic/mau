Then(/^I see a list of events/) do
  expect(page).to have_selector '.events .event .title'
end

Then(/^I see a list of months and years for existing events/) do
  expect(page).to have_selector 'nav.event_nav'
  keys = @events.map{|ev| ev.stime.strftime('%B %Y')}
  keys.each do |k|
    expect(page).to have_selector '.by_month a', k
  end
end

Then(/^I click on the calendar link$/) do
  all('a', :text => "View Events Calendar").first.click
end

Then(/^I see the events for that month$/) do
  key = @events.first.stime.strftime('%Y%m')
  expected_events = Event.published.select{|ev| ev.stime.strftime('%Y%m') == key }
  expect(expected_events).to have_at_least(1).event
  expected_events.each do |ev|
    expect(page).to have_selector('.title', :text => ev.title)
  end
end

When(/^I click on the first month link/) do
  link_text = @events.first.stime.strftime('%B %Y')
  click_link(link_text)
end