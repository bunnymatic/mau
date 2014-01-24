require 'pp'

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
  expect(page).to_not have_selector('.tagcloud .clouditem a', :text => @first_tag.name)
end

When(/^I destroy the first tag$/) do
  @first_tag = tags_sorted_by_frequency.first.first
  steps %{When I click on the first "Destroy" button}
end
