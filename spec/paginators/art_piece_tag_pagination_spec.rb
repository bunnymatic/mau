require 'spec_helper'

describe ArtPieceTagPagination do
  include PresenterSpecHelpers

  fixtures :art_piece_tags

  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:tag) { ArtPieceTag.last }
  let(:mode) { nil }

  subject(:paginator) do
    ArtPieceTagPagination.new(mock_view_context,
                              num_items.times.map{|x| x + 1},
                              tag, current_page, mode, per_page)
  end

  context 'with minimal arguments' do
    its(:previous_title) { should eq 'previous' }
    its(:previous_label) { should eq '&lt;prev' }
    its(:next_title) { should eq 'next' }
    its(:next_label) { should eq 'next&gt;' }
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
