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
  expect(page).to have_css '.paginator'
  expect(page).to have_content '>'
end

Then(/^I see more artists who have art in the most popular tag$/) do
  @first_tag = tags_sorted_by_frequency.first.first
  expect(page).to have_content @first_tag.name
  expect(page).to have_css '.paginator'
  expect(page).to have_content '<'
  expect(page).to have_content @first_tag.art_pieces.first.title
  expect(page).to_not have_content @first_tag.art_pieces.last.title
end


When(/^I click on the first tag$/) do
  tag_link = all('.art-piece__info art-piece-tag a').first
  tag_path = tag_link['href']
  @tag = ArtPieceTag.find( tag_path.gsub(/^\/art_piece_tags\//, '') )
  tag_link.click
end

Then(/^I see that tag detail page$/) do
  expect(current_path).to eql art_piece_tag_path(@tag)
  expect(page).to have_css '.header', text: @tag.name
  expect(page).to have_css '.tagcloud li'
  expect(page).to have_css ".art-card .tags a" do |tags|
    expect(tags.map{|t|t['href']}).to include art_piece_tag_path(@tag)
  end
end
