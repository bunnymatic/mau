When(/^I visit my home page$/) do
  visit artist_path(@artist)
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
  expect(page).to have_selector '.artist-pieces .allthumbs li .thumb', :count => @artist.art_pieces.count
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
end

Then(/^I see that my art was deleted$/) do
  @artist.reload
  expect(@artist.art_pieces.length).to eql @before_delete_count - 1
  expect(@artist.art_pieces.map(&:id)).to_not include @deleted_art_piece.id
end
