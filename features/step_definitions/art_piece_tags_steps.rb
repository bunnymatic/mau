# frozen_string_literal: true

Then(/^I don't see the first tag anymore$/) do
  expect(page).to_not have_selector('.tagcloud .clouditem a', text: /\A@first_tag.name\Z/)
end

When(/^I destroy the first tag$/) do
  @first_tag = ArtPieceTagService.tags_sorted_by_frequency.first
  steps %(When I click on the first "Remove" button)
end

Then(/^I see a list of artists who have art in the most popular tag$/) do
  @first_tag = ArtPieceTagService.tags_sorted_by_frequency.first

  expect(page).to have_css('h2.title', text: 'Tag')

  art_piece_names = page.all('.art-card .desc > .name:first-child').map(&:text)
  expect(art_piece_names & @first_tag.art_pieces.map(&:title)).to be_present

  expect(page).to have_css('.tag__name', text: @first_tag.name)
  expect(page).to have_css '.paginator'
  expect(page).to have_content '>'
  expect(page).to have_css '.paginator .current', text: '1'
end

Then(/^I see more artists who have art in the most popular tag$/) do
  @first_tag = ArtPieceTagService.tags_sorted_by_frequency.first

  expect(page).to have_css('h2.title', text: 'Tag')
  expect(page).to have_css('.tag__name', text: @first_tag.name)
  expect(page).to have_css '.paginator'
  expect(page).to have_css '.paginator .current', text: '2'

  # this preload/call (for some reason) sets this test up for success
  @first_tag.art_pieces.all

  name_tags = page.all('.search-results .desc .name')

  expect(name_tags.any? { |el| el.text =~ /#{@first_tag.art_pieces.first.title}/ }).to eq true
  expect(name_tags.any? { |el| el.text =~ /#{@first_tag.art_pieces.last.title}/ }).to eq false
end

When(/^I click on the first tag$/) do
  wait_until { page.find('art-piece-tag a') }

  name = page.find('art-piece-tag a').text
  @tag = ArtPieceTag.find_by(name: name)
  page.find('art-piece-tag a').click
end

Then(/^I see that tag detail page$/) do
  expect(page).to have_css('.art_piece_tags.show')
  expect(page).to have_css '.header', text: @tag.name
  expect(page).to have_css '.tagcloud li'
  expect(page).to have_css '.art-card'
  expect(current_path).to eql art_piece_tag_path(@tag)
end
