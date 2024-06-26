When(/^I click to add this as a favorite$/) do
  find('a.favorite-this').click
end

Then(/^I see all the favorites in a table$/) do
  expect(page_body).to have_content 'Favorites!'
  favs = User.all.map(&:favorites).sort_by(&:length).flatten.map(&:favoritable)
  totals = StatsCalculator.histogram(favs.map { |f| f.class.name })
  within 'tr.totals' do |row|
    expect(row).to have_content 'Total'
    expect(row).to have_css 'td', text: totals['ArtPiece'].to_s
    expect(row).to have_css 'td', text: totals['Artist'].to_s
  end
  user = User.distinct.joins(:favorites).sort_by { |ux| -ux.favorites.count }.detect { |f| f.is_a? MauFan }
  within(find('.user-entry', text: user.login)) do |row|
    expect(row).to have_link user.login, href: user_path(user)
    expect(row).to have_css 'td', text: user.favorites.count { |f| f.favoritable_type == 'ArtPiece' }.to_s
    expect(row).to have_css 'td', text: user.favorites.count { |f| f.favoritable_type == 'Artist' }.to_s
    expect(row).to have_css 'td', text: '0'
  end
end

When(/^I login as an artist with favorites$/) do
  @artist = Artist.first
  Artist.all[1..][0..3].each do |a|
    FavoritesService.add(@artist, a)
    FavoritesService.add(@artist, a.art_pieces.first) if a.art_pieces.present?
  end
  step 'I login'
end

When(/^I login as an artist without favorites$/) do
  @artist = Artist.first
  step 'I login'
end

When(/^I visit the favorites page for someone else$/) do
  @someone_else = Artist.last
  visit favorites_path(@someone_else)
end

When(/^I visit my favorites page$/) do
  visit favorites_path(@artist)
  @artist_favorites_count = @artist.favorites.count
end

Then(/^I see someone else's favorites$/) do
  expect(page_body).to have_content "#{@someone_else.get_name}'s Favorites"
  expect(page_body).to have_content 'has not favorited'
end

Then(/^I see my favorites$/) do
  expect(page_body).to have_content 'My Favorites'
  expect(page).to have_css('.art-card')
  expect(page).to have_css('.artist-card')
  expect(page).to have_css('.favorite-artists .section.header', text: "Artists (#{@artist.fav_artists.count})")
  expect(page).to have_css('.favorite-art-pieces .section.header', text: "Art Pieces (#{@artist.fav_art_pieces.count})")
end

Then(/^I see my empty favorites page$/) do
  expect(page_body).to have_content /Go find/
  expect(page_body).to have_content 'Find Artists by Name'
  expect(page_body).to have_content 'Find Artists by Medium'
  expect(page_body).to have_content 'Find Artists by Tag'
  expect(page).to have_css('.thumb')
end

When /^I remove the first favorite$/ do
  within first('.artist-card__remove-favorite') do
    click_on('Remove Favorite')
  end
end

Then /^I see that I've lost one of my favorites$/ do
  wait_until do
    all('.flash').any?
  end
  expect(@artist_favorites_count).to eql(@artist.reload.favorites.count + 1)
end
