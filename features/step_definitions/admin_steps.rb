Then(/^I see the admin dashboard$/) do
  expect(current_path).to eql admin_path
end

Then(/^I see the admin artists list$/) do
  expect(current_path).to eql admin_artists_path
end

When(/^I check the box for the first non-participating artist/) do
  @non_participating_artist = @artists.detect{|a| !a.os_participation}
  find("input[name=artist#{@non_participating_artist.id}]").click
end

Then(/^I see that the first non\-participating artist is participating$/) do
  expect(@non_participating_artist.reload.os_participating).to be_true
  expect(find("input[name=artist#{@non_participating_artist.id}]")['checked']).to eql 'checked'
end
