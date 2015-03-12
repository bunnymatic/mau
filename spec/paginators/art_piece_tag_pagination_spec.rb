require 'spec_helper'

describe ArtPieceTagPagination do
  include PresenterSpecHelpers
  let(:artist) { FactoryGirl.create :artist, :with_tagged_art }
  let(:art_pieces) { artist.art_pieces }
  let!(:tags) { artist.art_pieces.map(&:tags).flatten }
  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:tag) { tags.last }
  let(:mode) { nil }

  subject(:paginator) do
    ArtPieceTagPagination.new(num_items.times.map{|x| x + 1},
                              tag, current_page, mode, per_page)
  end

  context 'with minimal arguments' do
    its(:previous_title) { should eq 'previous' }
    its(:previous_label) { should eq '<' }
    its(:next_title) { should eq 'next' }
    its(:next_label) { should eq '>' }
    its(:next_link) { should eq art_piece_tag_path(tag, :p => 1) }
    its(:previous_link) { should eq art_piece_tag_path(tag, :p => 0) }
  end

  context 'with different mode' do
    let(:mode) { 's' }

    its(:next_link) { should eq art_piece_tag_path(tag, :p => 1, :m => 's') }
    its(:previous_link) { should eq art_piece_tag_path(tag, :p => 0, :m => 's') }
  end

  context 'with different current page' do
    let(:current_page) { 1 }

    its(:next_link) { should eq art_piece_tag_path(tag, :p => 2) }
    its(:previous_link) { should eq art_piece_tag_path(tag, :p => 0) }
  end


end
