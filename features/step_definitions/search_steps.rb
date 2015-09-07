When(/^I search for the first art piece by title$/) do
  step %Q|I search for "#{ArtPiece.first.title.split.first}"|
end

Then(/^I see the search results$/) do
  expect(page).to have_css 'search-results'
end

When(/^I search for the first art piece by artist name$/) do
  step %Q|I search for "#{ArtPiece.first.artist.firstname}"|
end

When(/^I search for "(.*?)"$/) do |query|
  fill_in 'Search for', with: query
  page.execute_script("$('.js-main-container form').submit()")
end

When(/^I refine my search to "(.*?)"$/) do |query|
  fill_in 'keywords', with: query
end

When(/^I refine my search to match lots of art$/) do
  def letter_frequency(words)
    Hash.new(0).tap do |letters|
      [words].flatten.compact.join.downcase.gsub(/\s+/,'').each_char {|c| letters[c] += 1 }
    end.sort_by{|letter, ct| ct}
  end
  letters = letter_frequency( Artist.open_studios_participants.map{|a| a.full_name})
  fill_in 'keywords', with: letters.last.first
end

    check Studio.by_position.first.name
