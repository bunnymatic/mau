# frozen_string_literal: true
require 'rails_helper'

describe MediumPagination, type: :controller do
  include PresenterSpecHelpers

  let(:artist) { FactoryBot.create :artist, :with_tagged_art }
  let(:art_pieces) { artist.art_pieces }
  let!(:media) { artist.art_pieces.map(&:medium) }
  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:medium) { media.last }
  let(:page_mode) {}

  subject(:paginator) do
    MediumPagination.new(Array.new(num_items) { |x| x + 1 },
                         medium, current_page, page_mode, per_page)
  end

  its(:previous_title) { should eq 'previous' }
  its(:previous_label) { should eq '<' }
  its(:next_title) { is_expected.to eq 'next' }
  its(:next_label) { is_expected.to eq '>' }
  its(:next_link) { is_expected.to eq mock_view_context.medium_path(medium, p: 1) }
  its(:previous_link) { is_expected.to eq mock_view_context.medium_path(medium, p: 0) }

  it '#link_to_next provides a link to the next page' do
    lnk = Capybara::Node::Simple.new(subject.link_to_next)

    expect(lnk).to have_selector('a')
    anchor = lnk.find('a')
    expect(anchor['href']).to eql subject.next_link
    expect(anchor['title']).to eql subject.next_title
  end

  it '#link_to_previous provides a link to the previous page' do
    lnk = Capybara::Node::Simple.new(subject.link_to_previous)
    expect(lnk).to have_selector('a')
    anchor = lnk.find('a')
    expect(anchor['href']).to eql subject.previous_link
    expect(anchor['title']).to eql subject.previous_title
  end

  context 'with different mode' do
    let(:page_mode) { 's' }
    its(:next_link) { is_expected.to eq medium_path(medium, m: 's', p: 1) }
    its(:previous_link) { is_expected.to eq medium_path(medium, m: 's', p: 0) }
  end

  context 'with different current page' do
    let(:current_page) { 1 }
    its(:next_link) { is_expected.to eq medium_path(medium, p: 2) }
    its(:previous_link) { is_expected.to eq medium_path(medium, p: 0) }
  end
end
