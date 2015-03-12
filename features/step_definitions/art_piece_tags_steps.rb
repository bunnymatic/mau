def tags_sorted_by_frequency
  all_tags = ArtPieceTag.all
  freq = ArtPieceTag.keyed_frequency
  all_tags.map do |tag|
    [tag, freq[tag.id].to_f]
  end.select(&:first).sort_by{|tag| [tag.last, tag.first.id]}.reverse
end

Then(/^I see the most popular tag page$/) do
  first_tag = tags_sorted_by_frequency.first.first
  expect(current_path).to eql art_piece_tag_path(first_tag)
end

Then(/^I don't see the first tag anymore$/) do
  expect(page).to_not have_selector('.tagcloud .clouditem a', text: /\A@first_tag.name\Z/)
end

When(/^I destroy the first tag$/) do
  @first_tag = tags_sorted_by_frequency.first.first
  steps %{When I click on the first "Remove" button}
end

Then(/^I see a list of artists who have art in the most popular tag$/) do
  @first_tag = tags_sorted_by_frequency.first.first
  expect(page).to have_content @first_tag.art_pieces.last.title
  expect(page).to have_content @first_tag.name
  expect(page).to have_content 'page 1 of'
  expect(page).to have_content 'next>'
end

Then(/^I see more artists who have art in the most popular tag$/) do
  @first_tag = tags_sorted_by_frequency.first.first
  expect(page).to have_content @first_tag.name
  expect(page).to have_content 'page 2 of'
  expect(page).to have_content '<prev'
  expect(page).to have_content @first_tag.art_pieces.first.title
  expect(page).to_not have_content @first_tag.art_pieces.last.title
end


When(/^I click on the first tag$/) do
  tag_link = all('.art-piece__info tag a').first
  tag_path = tag_link['href']
  @tag = ArtPiceTag.find( tag_path.gsub(/^\/media\//, '') )
  tag_link.click
end

Then(/^I see that tag detail page$/) do
  expect(current_path).to eql art_piece_tag_path(@tag)
  expect(page).to have_content @tag.name
  expect(page).to have_css '.tagcloud li'
  expect(page).to have_css ".art-card .media a" do |tags|
    tags.each do |tag|
      expect(tag['href']).to eql art_piece_tag_path(@tag)
    end
  end
end
