def find_admin_user_show_row(title)
  page.all('.admin-user__show-table tbody tr').detect { |row| row.text.include? title }
end

When /^I set all artists to do open studios$/ do
  within('#good .js-data-tables') do
    all('[type=checkbox]').each do |cb|
      check cb['id']
    end
  end
  scroll_to_position(0, 0) # ('.admin-table__controls .update-artists')
  click_on_first 'update os status'
end

Then(/^I see the admin dashboard$/) do
  expect(current_path).to eql admin_path
end

Then(/^I see the admin artists list$/) do
  if running_js?
    wait_until do
      all('#good table, #bad #table').count.positive?
    end
  else
    wait_until { current_path == admin_artists_path }
  end
end

When(/^I uncheck the box for the first participating artist/) do
  cb = first('#good table input[checked=checked]')
  id = cb['id']
  uncheck cb['id']
  scroll_to_position(0, 0) # ('.admin-table__controls .update-artists')
  click_on_first 'update os status'
  @participating_artist = Artist.find(id.split('_').last)
end

Then(/^I see that the first participating artist is no longer doing open studios/) do
  expect(page).to have_flash :notice, /updated setting/i

  within(table_row_matching(@participating_artist.login)) do
    expect(page).to have_field("os_#{@participating_artist.id}", checked: false)
  end
end

Then /^I see that all artists are doing open studios$/ do
  expect(@artists).to have_at_least(1).artist
  expect(page).to have_flash :notice, /updated setting for/i
  expect(@artists.map { |a| a.reload.doing_open_studios? }.all?).to eq true
end

When(/^I remove the first artist from the studio$/) do
  anchor = first('a.unaffiliate')
  artist_id = anchor['href'].split('?').last.split('=').last
  @unaffiliated_artist = Artist.find(artist_id)
  expect(page).to have_content @unaffiliated_artist.full_name
  anchor.click
end

Then(/^I see that artist is no longer part of the studio list$/) do
  expect(page).to_not have_content @unaffiliated_artist.full_name
end

When(/^I suspend the first artist$/) do
  wait_until do
    !all('#good .admin-table tr').empty?
  end

  name = first('#good table tbody tr a.admin-artist-suspend-link').ancestor('tr').find('td.login').text
  @first_artist = Artist.find_by(login: name)
  click_on_first 'Suspend artist'
end

Then(/^I see the first artist in that table$/) do
  wait_until do
    !all('.admin-table tr').empty?
  end
  expect(table_row_matching(@first_artist.login)).to be_present
end

When(/^I edit my studio$/) do
  visit edit_admin_studio_path((@manager || @user).studio)
end

Then /^I see everyone who is "([^"]*)"$/ do |artist_state|
  expect(page).to have_css "table tr.#{artist_state}", count: Artist.send(artist_state).count
end

When(/^I click on the first artist edit button that's not me$/) do
  not_me = Artist.active.limit(2).detect { |a| a.login != (@artist.login || @user.login) }
  cell = page.all('table tr').detect { |el| el.text.include? not_me.login }
  cell.find('.admin-artist-edit-link').click
end

When(/^I click on the first open studios artist edit button that's not me$/) do
  not_me = Artist.active.joins(:open_studios_participants).detect { |a| a.login != (@artist.login || @user.login) }
  cell = page.all('table tr').detect { |el| el.text.include? not_me.login }
  cell.find('.admin-artist-edit-link').click
end

When(/^I see the admin artist show page with updated values:$/) do |expected_values|
  expect(page.find('.admin.users .artist-admin-header .title')).to have_text(@artist.name || @user.name)

  expected_values.hashes.first.each do |entry, value|
    row = find_admin_user_show_row(entry)
    expect(row).to be_present
    expect(row.all('td').last).to have_content(value)
  end
end

When(/^I see the admin artist show page with updated open studios participant values:$/) do |expected_values|
  expect(page.find('.admin.users .artist-admin-header .title')).to have_text(@artist.name || @user.name)

  expected_values.hashes.first.each do |entry, value|
    row = find_admin_user_show_row(entry)
    expect(row).to be_present
    expect(row.all('td').last).to have_content(value)
  end
end

When(/^I see that the admin artist pages shows that artist in studio "([^"]*)"$/) do |studio_name|
  row = find_admin_user_show_row('Studio')
  expect(row).to be_present
  expect(row.all('td').last).to have_content(studio_name)
end

Then(/^I see the "([^"]*)" admin stats$/) do |type|
  type.gsub!(/\s+/, '_')
  expect(page).to have_css(".dashboard__stats-list.#{type} table")
end

When(/^as an admin I choose every other time slot for the video conference schedule/) do
  within '.admin-artists-edit__section' do
    page.all("[type='checkbox']").each_slice(2) do |cb|
      cb[0].click
    end
  end
end

When('I see that the artist is scheduled for every other time slot') do
  within '.admin-user__os-info' do
    page.all("[type='checkbox']").each_slice(2) do |cb|
      expect(cb[0].checked?).to eq true
      expect(cb[1].checked?).to eq false
    end
  end
end
