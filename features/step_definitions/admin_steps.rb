When /^I set all artists to do open studios$/ do
  within('#good table') do
    all('[type=checkbox]').each do |cb|
      check cb['id']
    end
  end
  click_on_first 'update os status'
end

Then(/^I see the admin dashboard$/) do
  expect(current_path).to eql admin_path
end

Then(/^I see the admin artists list$/) do
  expect(current_path).to eql admin_artists_path
end

When(/^I uncheck the box for the first participating artist/) do
  cb = all('#good table input[checked=checked]').first
  id = cb['id']
  uncheck cb['id']
  click_on_first 'update os status'
  @participating_artist = Artist.find(id.split("_").last)
end

Then(/^I see that the first participating artist is no longer doing open studios/) do
  @participating_artist = Artist.find(@participating_artist.id) # force reload with artist info reload
  expect(@participating_artist.doing_open_studios?).to be_false
end

Then /^I see that all artists are doing open studios$/ do
  expect(@artists).to have_at_least(1).artist
  expect(page).to have_selector '.flash__notice', :text => 'Updated setting for'
  expect(@artists.map(&:doing_open_studios?).all?).to be_true
end

When(/^I remove the first artist from the studio$/) do
  anchor = all('a.unaffiliate').first
  artist_id = anchor['href'].split("?").last.split("=").last
  @unaffiliated_artist = Artist.find(artist_id)
  expect(page).to have_content @unaffiliated_artist.full_name
  anchor.click
end

Then(/^I see that artist is no longer part of the studio list$/) do
  expect(page).to_not have_content @unaffiliated_artist.full_name
end

When(/^I suspend the first artist$/) do
  name = page.all('#good table tbody tr td.login a').first.text
  @first_artist = Artist.find_by_login(name)
  click_on_first 'Suspend artist'
end

Then(/^I see that the first artist is suspended$/) do
  expect(@first_artist.reload).to be_suspended
end

When(/^I edit my studio$/) do
  visit edit_admin_studio_path( (@manager || @user).studio )
end

Then /^I can see everyone who is "([^"]*)"$/ do |artist_state|
  expect(page).to have_css "table tr.#{artist_state}", count: Artist.send(artist_state).count
end
