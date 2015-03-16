When(/^I visit my home page$/) do
  visit artist_path(@artist)
end

When(/^I visit my profile edit page$/) do
  visit edit_artist_path(@artist)
end

When(/^I fill out the add art form$/) do
  @medium = Medium.first
  attach_file "Select File", File.join(Rails.root,"/spec/fixtures/art.png")
  fill_in "Title", with: 'Mona Lisa'
  fill_in "Dimensions", with: '4 x 3'
  fill_in "Year", with: '1515'
  select @medium.name, from: "Medium"
  fill_in "Tags", with: "this, and that"
end

Then /^I see that my art was added$/ do
  expect(page).to have_content "Mona Lisa"
end

When(/^I rearrange my art with drag and drop$/) do
  expect(@artist.art_pieces).to be_present
  expect(page).to have_selector('.sortable')
  @old_order = @artist.art_pieces.map(&:id)

  images = page.all('.allthumbs.sortable li.thumb')
  images.first.drag_to(images.third)
  click_on 'save'
  @new_order = @artist.art_pieces.map(&:id)
end

Then(/^I see my art$/) do
  expect(@artist.art_pieces).to be_present
  expect(page).to have_selector '.art-card .image'
end

Then(/^I see the artist's menu/) do
  expect(page).to have_selector '.nav-section.users'
end

Then(/^I can arrange my art$/) do
  expect(current_path).to eql manage_art_artist_path(@artist)
end

Then(/^I can delete my art$/) do
  expect(current_path).to eql manage_art_artist_path(@artist)
  expect(page).to have_selector '#delete_art li.art-card .image'
end

When(/^I mark art for deletion$/) do
  @before_delete_count = @artist.art_pieces.length
  @deleted_art_piece = @artist.art_pieces.first
  check "art_#{@deleted_art_piece.id}"
  click_on 'Delete Selected Images'
  @artist.reload
end

Then(/^I see that my art was deleted$/) do
  expect(@artist.art_pieces.length).to eql @before_delete_count - 1
  expect(@artist.art_pieces.map(&:id)).to_not include @deleted_art_piece.id
end

Then(/^I see my profile edit form$/) do
  expect(page).to have_css '.panel-heading', count: 8
end

When(/^I update my personal information with:$/) do |table|
  info = table.hashes.first
  info.each do |field, val|
    fill_in field, with: val
  end
end

When(/^I see my updated personal information as:$/) do |table|
  info = table.hashes.first
  info.each do |field, val|
    expect(find_field(field).value).to eql val
  end
end

When /^that artist is not doing open studios$/ do
  @artist.update_os_participation OpenStudiosEvent.current, false
end

When /^I click on the current open studios edit section$/ do
  click_on "Open Studios #{OpenStudiosEvent.current.for_display(true)}"
end

Then(/^I see that I've successfully signed up for Open Studios$/) do
  expect(@artist.reload.doing_open_studios?).to eq true
end

Then(/^I see that I've successfully unsigned up for Open Studios$/) do
  expect(@artist.reload.doing_open_studios?).to eq false
end

When(/^I click on the first artist's card$/) do
  @artist = Artist.active.all.detect{|a| a.art_pieces.present?}
  click_on_first @artist.full_name
end

Then(/^I see that artist's profile page$/) do
  expect(page).to have_css '.header', text: @artist.full_name
  expect(page).to have_css '.artist-profile'
  expect(page).to have_content @artist.facebook
  expect(page).to have_content @artist.primary_medium.name
  expect(current_path).to eql artist_path(@artist)
end

When(/^I click on an art card$/) do
  first_art_card = all('.art-card a').first
  first_art_card.trigger('click')
end

Then(/^I see that art piece detail page$/) do
  expect(page).to have_css('art-pieces-browser')
  expect(page).to have_css '.header', text: @artist.full_name
  
end
