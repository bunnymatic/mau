Given(/^I'm on the subdomain "?([^"]*)"?$/) do |site_domain|
  site_domain = 'openstudios.lvh.me' if site_domain == 'openstudios'

  host! site_domain
  Capybara.app_host = "http://#{site_domain}"
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
