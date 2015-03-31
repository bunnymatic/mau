def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end
Then(/^I see all the favorites in a table$/) do
  expect(page).to have_content 'Favorites!'
  favs = User.all.map(&:favorites).sort{|x| x.length}.flatten.map(&:to_obj)
  totals = histogram(favs.map{|f| f.class.name})
  within 'tr.totals' do
    expect(page).to have_content "Total"
    expect(page).to have_css 'td', text: totals["ArtPiece"].to_s
    expect(page).to have_css 'td', text: totals["Artist"].to_s
  end
  u = User.select{|u| u.favorites.present?}.sort{|u| -u.favorites.count}.detect{|f| f.is_a? MAUFan}
  within (find('.user-entry', text: u.login)) do
    expect(page).to have_link u.login, href: user_path(u)
    expect(page).to have_css 'td', text: u.favorites.select{|f| f.favoritable_type == 'ArtPiece'}.count.to_s
    expect(page).to have_css 'td', text: u.favorites.select{|f| f.favoritable_type == 'Artist'}.count.to_s
    expect(page).to have_css 'td', text: '0'
  end
end


When(/^I login as an artist with favorites$/) do
  @artist = Artist.first
  Artist.all[1..-1][0..3].each do |a|
    @artist.add_favorite a
    if a.art_pieces.present? 
      @artist.add_favorite a.art_pieces.first
    end
  end
  step "I login"
end

When(/^I login as an artist without favorites$/) do
  @artist = Artist.first
  step "I login"
end

When(/^I visit the favorites page for someone else$/) do
  @someone_else = Artist.last
  visit favorites_path(@someone_else)
end

When(/^I visit my favorites page$/) do
  visit favorites_path(@artist)
end

Then(/^I see someone else's favorites$/) do
  expect(page).to have_content "#{@someone_else.get_name}'s Favorites"
  expect(page).to have_content 'has not favorited'
end

Then(/^I see my favorites$/) do
  expect(page).to have_content 'My Favorites'
  expect(page).to have_css('.art-card')
  expect(page).to have_css('.artist-card') 
  expect(page).to have_css('.favorite-artists .section.header', text: "Artists (#{@artist.fav_artists.count})")
  expect(page).to have_css('.favorite-art-pieces .section.header', text: "Art Pieces (#{@artist.fav_art_pieces.count})")
end

Then(/^I see my empty favorites page$/) do
  expect(page).to have_content /Go find/
  expect(page).to have_content 'Find Artists by Name'
  expect(page).to have_content 'Find Artists by Medium'
  expect(page).to have_content 'Find Artists by Tag'
end
