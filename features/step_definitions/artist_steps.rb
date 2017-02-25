# frozen_string_literal: true
When(/^I visit my home page$/) do
  visit artist_path(@artist)
end

When(/^I visit my artist profile edit page$/) do
  visit edit_artist_path(@artist)
end

When(/^I visit my user profile edit page$/) do
  visit edit_artist_path(@user)
end

Then(/^I see that my art title was updated to "(.*?)"$/) do |new_title|
  wait_until do
    title = all('.title').map(&:text).join
    /#{new_title}/i =~ title
  end
  within '.title' do
    expect(page).to_not have_content "Mona Lisa"
    expect(page).to have_content new_title
  end
end

When(/^I update the medium to the last medium$/) do
  selectize_single_select "art_piece_medium_id", Medium.last.name
end

Then(/^I see that my art medium was updated to the last medium$/) do
  within ".media" do
    expect(page).to have_content(Medium.last.name)
  end
end

When(/^I update the art piece tags to:/) do |data|
  selectize_multi_select "art_piece_tag_ids", data.raw
end

Then(/^I see that my art tags are:$/) do |data|
  expected_tags = data.raw.first
  within '.tags' do
    expected_tags.each do |tag|
      expect(page).to have_content tag
    end
  end
end

When(/^I fill out the add art form$/) do
  @medium = Medium.first
  attach_file "Photo", File.join(Rails.root,"/spec/fixtures/files/art.png")
  fill_in "Title", with: 'Mona Lisa'
  fill_in "Dimensions", with: '4 x 3'
  fill_in "Year", with: '1515'
  selectize_single_select "art_piece_medium_id", @medium.name
  selectize_multi_select "art_piece_tag_ids", %w(superfragile complimicated)
end

Then /^I see that my art was added$/ do
  expect(page).to have_content "Mona Lisa"
  expect(page).to have_content "complimicated, superfragile"
  expect(page).to have_content @medium.name
end

Then /^I see that my art was not added$/ do
  within '.error-msg' do
    expect(page).to have_content "Title can't be blank"
  end
  expect(page).to have_css "#art_piece_title_input.error"
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

When /^I move the last image to the first position$/ do
  @last_piece = @artist.art_pieces.last
  card = page.all('.js-sortable li').last
  target = page.all('.js-sortable li').first
  card.drag_to(target)
end

Then /^I see that my representative image has been updated$/ do
  expect(all('.art-card').first['data-id']).to eql @last_piece.id.to_s
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
  @artist.update_os_participation OpenStudiosEventService.current, false
end

When /^that artist is doing open studios$/ do
  @artist.update_os_participation OpenStudiosEventService.current, true
end

When /^I click on the current open studios edit section$/ do
  click_on "Open Studios #{OpenStudiosEventService.current.for_display(true)}"
end

Then(/^I see that I've successfully signed up for Open Studios$/) do
  @artist = Artist.find(@artist.id) # force reload with artist info reload
  expect(@artist.doing_open_studios?).to eq true
end

Then(/^I see that I've successfully unsigned up for Open Studios$/) do
  @artist = Artist.find(@artist.id) # force reload with artist info reload
  expect(@artist.doing_open_studios?).to eq false
end

When(/^I click on the first artist's card$/) do
  @artist = Artist.active.all.detect{|a| a.representative_piece.present?}
  click_on_first @artist.full_name
  expect(page).to have_css('.artists.show');
end

Then(/^I see "([^"]*)"'s artist card$/) do |name|
  first_name, last_name = name.split(/\s+/).map(&:strip)
  @artist = Artist.where(firstname: first_name, lastname: last_name).first
  expect(page).to have_css('.artist-card', text: name)
end

When(/^I click on "([^"]*)"'s artist card$/) do |name|
  first_name, last_name = name.split(/\s+/).map(&:strip)
  @artist = Artist.where(firstname: first_name, lastname: last_name).first
  click_on_first name
end

Then(/^I see that artist's profile page$/) do
  expect(page).to have_css '.header', text: @artist.full_name
  expect(page).to have_css '.artist-profile'
  expect(page).to have_content @artist.facebook
  expect(page).to have_content @artist.art_pieces.first.medium.name
  expect(current_path).to eql artist_path(@artist)
end

When(/^I click on an art card$/) do
  art_card = all('.art-card a .image').first
  if running_js?
    art_card.trigger('click')
  else
    art_card.click
  end

  @art_piece = @artist.art_pieces.first
  expect(page).to have_css('.art_pieces.show')
end

Then(/^I see that art piece detail page$/) do
  expect(page).to have_css('art-pieces-browser')
  expect(page).to have_css '.header', text: @artist.full_name
end

When(/^I submit a new profile picture$/) do
  find('.file.input')
  attach_file "Photo", File.join(Rails.root,"/spec/fixtures/files/art.png")
end

Then(/^I see that I have a new profile picture$/) do
  img = find(".artist-profile__image img")
  expect(img).to be_present
end

Then(/^the artists index page shows no artists for open studios$/) do
  expect(page).to_not have_css '.artist-card'
  expect(page).to have_css 'h2', text: "Artists in Open Studios"
  expect(page).to have_content 'Sorry, no one has signed up for the next Open Studios'
end

Then(/^I see open studios artists on the artists list$/) do
  expect(page).to have_css '.artist-card'
  expect(page).to have_css 'h2', text: "Artists in #{OpenStudiosEventService.current.for_display(true)} Open Studios"
end

Then(/^the meta description includes the artist's bio$/) do
  %q{Then the page meta name "description" includes "#{@artist.bio.first(50)}"}
  %q{Then the page meta property "og:description" includes "#{@artist.bio.first(50)}"}
end

When(/^the meta description includes that art piece's title$/) do
  %q(Then the page meta name "description" includes "#{@art_piece.title}")
  %q(Then the page meta property "og:description" includes "#{@art_piece.title}")
end

When(/^the meta keywords includes that art piece's tags and medium$/) do
  @art_piece.tags.each do |_tag|
    %q(Then the page meta name "keywords" includes "#{tag.name}")
  end
  if @art_piece.medium
    %q(Then the page meta name "keywords" includes "#{@art_piece.medium.name}")
  end
end
