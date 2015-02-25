When /^I set all artists to do open studios$/ do
  within('table.admin-table') do
    for artist in @artists
      cb = "os_#{artist.id}"
      check cb
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
  @participating_artist = @artists.detect{|a| a.doing_open_studios? && a.has_address?}
  uncheck "os_#{@participating_artist.id}"
  click_on_first 'update os status'
end

Then(/^I see that the first participating artist is no longer doing open studios/) do
  expect(@participating_artist.reload.doing_open_studios?).to be_false
end

Then /^I see that all artists are doing open studios$/ do
  expect(@artists).to have_at_least(1).artist
  expect(page).to have_selector '.flash__notice', :text => 'Updated setting for'
  expect(@artists.map(&:doing_open_studios?).all?).to be_true
end
