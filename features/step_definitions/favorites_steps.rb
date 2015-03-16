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

