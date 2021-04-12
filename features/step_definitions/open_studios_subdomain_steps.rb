OPEN_STUDIOS_SUBDOMAIN = 'openstudios.lvh.me'.freeze

Given(/^I visit "?([^"]*)"? in the catalog$/) do |path|
  visit "http://#{OPEN_STUDIOS_SUBDOMAIN}/#{path}"
end

Then('I see pictures from all participating artists') do
  artist_names = OpenStudiosParticipant.all.map(&:user).map(&:get_name)
  expect(artist_names).to have_at_least(1).name

  artist_names.each do |name|
    expect(page).to have_content(name)
  end
  expect(page.all('#participants .artist-card')).to have(artist_names.size).cards
end

Then('I see the open studios catalog cms message') do
  expect(page).to have_content('This is about the catalog preview')
  within('.section.markdown h2') do
    expect(page).to have_content('this is going to rock (catalog summary)')
  end
end

When /I visit my open studios catalog page/ do
  step %(I visit "#{artist_path(@artist)} in the catalog)
end
