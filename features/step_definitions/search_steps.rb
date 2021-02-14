When(/^I search for the first art piece by title$/) do
  step %(I search for "#{ArtPiece.first.title.split.first}")
end

When(/^I search for the first art piece by artist name$/) do
  step %(I search for "#{ArtPiece.first.artist.firstname.upcase}")
end

When(/^I search for "(.*?)"$/) do |query|
  find('#search_query').send_keys(query)
end

Then(/^I see "([^"]*)" in the search results$/) do |keyword|
  within 'search-results' do
    expect(page).to have_content(/#{Regexp.quote(keyword)}/i)
  end
end

Then(/^I see the search results have the first art piece$/) do
  step %(I see "#{ArtPiece.first.title}" in the search results)
end
