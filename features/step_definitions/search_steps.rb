When(/^I search for the first art piece by title$/) do
  step %Q|I search for "#{ArtPiece.first.title.split.first}"|
end

Then(/^I see the search results have the first art piece$/) do
  within '#search_results' do
    expect(page).to have_css('.art-card')
    expect(page).to have_content ArtPiece.first.title
  end
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

Then(/^I see the search results have pieces from the first medium$/) do
  expect(page).to have_content Medium.first.name
  within '#search_results' do
    expect(page).to have_css('.art-card')
  end
end

When(/^I check the first studio filter$/) do
  within '#studio_chooser' do
    check Studio.first.name
  end
end

When(/^I check the first media filter$/) do
  within '#medium_chooser' do
    check Medium.first.name
  end
end

When(/^I uncheck the first media filter$/) do
  within '#medium_chooser' do
    uncheck Medium.first.name
  end
end

Then(/^I see the search results have pieces from the first studio$/) do
  within '#search_results' do
    expect(page).to have_css('.art-card')
  end
end

Then(/^I see the search results are empty$/) do
  within '#search_results' do
    expect(page).not_to have_css('.art-card')
    expect(page).to have_content "anything that matched your"
  end
end

Then(/^I see the search results have only open studios participant art$/) do
  
  within '#search_results .search-results' do
    expect('.art-card').to be_present
    art_cards = page.all('.art-card')
    art_cards.each do |card|
      expect(card).to have_css '.os-violator'
    end
  end
end
