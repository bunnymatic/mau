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

Then(/^I see the results are saved$/) do
  assert false
end
