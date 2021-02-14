When(/^I visit my home page$/) do
  visit artist_path(@artist)
end

When(/^I visit my\s+(artist\s+)?(profile\s+)?edit page$/) do |_dummy, _dummy2|
  visit edit_artist_path(@artist)
end

When(/^I visit my user profile edit page$/) do
  visit edit_artist_path(@user)
end

Then(/^I see that my art title was updated to "(.*?)"$/) do |new_title|
  wait_until do
    title = all('.title').map(&:text).join
    /#{Regexp.quote(new_title)}/i =~ title
  end
  within '.title' do
    expect(page).to_not have_content 'Mona Lisa'
    expect(page).to have_content new_title
  end
end

When(/^I update the medium to the last medium$/) do
  select2 Medium.last.name, from: 'Medium'
end

Then(/^I see that my art medium was updated to the last medium$/) do
  within '.media' do
    expect(page).to have_content(Medium.last.name)
  end
end

When(/^I update the art piece tags to:/) do |data|
  select2(*data.raw.flatten, from: 'Tags', tag: true)
end

Then(/^I see that my art tags are:$/) do |data|
  expected_tags = data.raw.first
  within '.tags' do
    expected_tags.each do |tag|
      expect(page).to have_content tag
    end
  end
end

Then('I see that my art is marked sold') do
  expect(page).to have_css('.desc__item--sold')
end

Then('I see the sold checkmark is checked') do
  within 'form' do
    expect(page).to have_css('#art_piece_sold[checked]')
  end
end

When(/^I fill out the add art form$/) do
  @medium = Medium.first
  attach_file 'Photo', Rails.root.join('spec/fixtures/files/art.png')
  fill_in 'Title', with: 'Mona Lisa'
  fill_in 'Dimensions', with: '4 x 3'
  fill_in 'Year', with: '1515'
  fill_in 'Price', with: '100'
  select2 @medium.name, from: 'Medium', exact: true
  select2 'superfragile', 'complimicated', from: 'Tags', tag: true
end

Then /^I see that my art was added$/ do
  expect(page).to have_content 'Mona Lisa'
  expect(page).to have_content 'complimicated, superfragile'
  expect(page).to have_content @medium.name
  expect(page).to have_content '$100'
end

Then /^I see that my art was not added$/ do
  within '.error-msg' do
    expect(page).to have_content "Title can't be blank"
  end
  expect(page).to have_css '#art_piece_title_input.error'
end

Then(/^I see my art$/) do
  expect(@artist.art_pieces).to be_present
  expect(page).to have_selector '.art-card .image'
end

When /^I move the last image to the first position$/ do
  @last_piece = @artist.art_pieces.last
  card = all('.js-sortable li').last
  target = first('.js-sortable li')
  card.drag_to(target)
  sleep(1)
end

Then /^I see that my representative image has been updated$/ do
  expect(first('.art-card')['data-id']).to eql @last_piece.id.to_s
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
  expect(page).to have_css '.panel-heading'
  expect(all('.panel-heading')).to have_at_least(6).panels
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
  OpenStudiosParticipationService.refrain(@artist, OpenStudiosEventService.current)
end

When /^that artist is doing open studios$/ do
  OpenStudiosParticipationService.participate(@artist, OpenStudiosEventService.current)
end

When /^I click on the current open studios edit section$/ do
  link_text = OpenStudiosEventPresenter.new(OpenStudiosEventService.current).link_text
  click_on "Open Studios #{link_text}"
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
  @artist = Artist.active.all.detect { |a| a.representative_piece.present? }
  click_on_first @artist.full_name
  expect(page).to have_css('.artists.show')
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

Then(/^I see the "([^"]*)" profile panel is open/) do |panel_id|
  expect(page).to have_css("##{panel_id}.panel-collapse.in")
end

When(/^I click on an art card$/) do
  art_card = first('.art-card a .image')
  if running_js?
    begin
      art_card.trigger('click')
    rescue Capybara::NotSupportedByDriverError
      art_card.click
    end
  else
    art_card.click
  end

  # @art_piece = @artist.art_pieces.first
  # puts ".art-card a[href=#{art_piece_path(@art_piece)}]"
  # find(:link_href, art_piece_path(@art_piece)).click
  expect(page).to have_css('.art_pieces.show')
  # puts @art_piece.tags.count
end

Then(/^I see that art piece detail page$/) do
  expect(page).to have_css('art-pieces-browser')
  expect(page).to have_css '.art-piece__byline', text: @artist.full_name
  page.current_path =~ %r{art_pieces/(\d+).*}
  @art_piece = ArtPiece.find_by(id: $1)
end

When(/^I open the "([^"]*)" profile section/) do |title|
  trigger = all('.panel-title a').detect { |h4| h4.text.include?(title) }
  trigger.click
end

When(/^I submit a new profile picture$/) do
  find('.file.input')
  attach_file 'Photo', Rails.root.join('spec/fixtures/files/user.png')
end

Then(/^I see that I have a new profile picture$/) do
  img = find('.artist-profile__image img')
  expect(img).to be_present
end

Then(/^I see open studios artists on the artists list$/) do
  expect(page).to have_css '.artist-card'
  expect(page).to have_css 'h2', text: "Artists in #{OpenStudiosEventService.current.for_display(reverse: true)} Open Studios"
end

Then(/^the meta description includes the artist's bio$/) do
  steps %(Then the page meta name "description" includes "#{@artist.bio.first(50)}")
  steps %(Then the page meta property "og:description" includes "#{@artist.bio.first(50)}")
end

When(/^the meta description includes that art piece's title$/) do
  steps %(Then the page meta name "description" includes "#{@art_piece.title}")
  steps %(Then the page meta property "og:description" includes "#{@art_piece.title}")
end

When(/^the meta keywords includes that art piece's tags and medium$/) do
  @art_piece.tags.each do |tag|
    steps %(Then the page meta name "keywords" includes "#{tag.name}")
  end
  steps %(Then the page meta name "keywords" includes "#{@art_piece.medium.name}") if @art_piece.medium
end
