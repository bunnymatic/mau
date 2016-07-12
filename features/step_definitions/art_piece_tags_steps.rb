Then(/^I see the most popular tag page$/) do
  first_tag = ArtPieceTagService.tags_sorted_by_frequency.first.tag
  expect(current_path).to eql art_piece_tag_path(first_tag)
end

Then(/^I don't see the first tag anymore$/) do
  expect(page).to_not have_selector(".tagcloud .clouditem a", text: /\A@first_tag.name\Z/)
end

When(/^I destroy the first tag$/) do
  @first_tag = ArtPieceTagService.tags_sorted_by_frequency.first
  steps %{When I click on the first "Remove" button}
end

Then(/^I see a list of artists who have art in the most popular tag$/) do
  @first_tag = ArtPieceTagService.tags_sorted_by_frequency.first.tag
  expect(page).to have_css("h2.title", text: "Tag")
  expect(page).to have_content @first_tag.art_pieces.last.title
  expect(page).to have_content @first_tag.name
  expect(page).to have_css ".paginator"
  expect(page).to have_content ">"
  expect(page).to have_css ".paginator .current", text: "1"
end

Then(/^I see more artists who have art in the most popular tag$/) do
  @first_tag = ArtPieceTagService.tags_sorted_by_frequency.first.tag

  expect(page).to have_content @first_tag.name
  expect(page).to have_css ".paginator"
  expect(page).to have_css ".paginator .current", text: "2"

  # this preload/call (for some reason) sets this test up for success
  @first_tag.art_pieces.all

  within ".search-results" do
    expect(page).to have_content @first_tag.art_pieces.first.title
    expect(page).to_not have_content @first_tag.art_pieces.last.title
  end
end


When(/^I click on the first tag$/) do
  wait_until { page.find("art-piece-tag a") }
  tag_link = all(".art-piece__info art-piece-tag a").first
  tag_path = tag_link["href"]
  @tag = ArtPieceTag.find( tag_path.gsub(/^\/art_piece_tags\//, "") )
  tag_link.click
end

Then(/^I see that tag detail page$/) do
  expect(current_path).to eql art_piece_tag_path(@tag)
  expect(page).to have_css ".header", text: @tag.name
  expect(page).to have_css ".tagcloud li"
  expect(page).to have_css ".art-card"
end
