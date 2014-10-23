When(/^I visit my home page$/) do
  visit artist_path(@artist)
end

When(/^I visit my profile edit page$/) do
  visit edit_artist_path(@artist)
end

When(/^I rearrange my art with drag and drop$/) do
  expect(@artist.art_pieces).to be_present
  expect(page).to have_selector('.sortable')
  @old_order = @artist.art_pieces.map(&:id)

  images = page.all('.allthumbs.sortable li.thumb')
  images.first.drag_to(images.third)
  click_on 'save'
  puts @old_order
  @new_order = @artist.art_pieces.map(&:id)
end

Then(/^I see my big thumbs on the left/) do
  expect(@artist.art_pieces).to be_present
  expect(page).to have_selector '#bigthumbcolumn ul.allthumbs li', :count => 4
end

Then(/^I see my art$/) do
  expect(@artist.art_pieces).to be_present
  expect(page).to have_selector '.artist-pieces .allthumbs li .thumb', :count => @artist.art_pieces.length
end

Then(/^I see the artist's menu/) do
  expect(@artist.art_pieces).to be_present
  expect(page).to have_selector '#sidebar_nav .leaf'
end

Then(/^I can arrange my art$/) do
  expect(current_path).to eql arrange_art_artists_path
end

Then(/^I can delete my art$/) do
  expect(current_path).to eql delete_art_artists_path
  expect(page).to have_selector '#delete_art li.artp-thumb-container input[type=checkbox]'
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
  expect(page).to have_css '.open-close-div', count: 8
  expect(page).to have_css '.edit-profile-sxn', count: 8, visible: false
end

When(/^I update my personal information with:$/) do |table|
  info = table.hashes.first
  info.each do |field, val|
    fill_in field, with: val
  end
  click_on_first "Save Changes"
end

When(/^I see my updated personal information as:$/) do |table|
  info = table.hashes.first
  info.each do |field, val|
    expect(find_field(field).value).to eql val
  end
end

Then(/^I see that I've successfully signed up for Open Studios$/) do
  expect(@artist.reload.doing_open_studios?).to eq true
end

Then(/^I see that I've successfully unsigned up for Open Studios$/) do
  expect(@artist.reload.doing_open_studios?).to eq false
end
