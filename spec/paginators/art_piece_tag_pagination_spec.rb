require 'spec_helper'

describe ArtPieceTagPagination do
  include PresenterSpecHelpers

  fixtures :art_piece_tags

  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:tag) { ArtPieceTag.last }
  let(:page_args) { {} }

  subject(:paginator) { ArtPieceTagPagination.new(mock_view_context, num_items.times.map{|x| x + 1}, tag, current_page, page_args, per_page) }

  context 'with minimal arguments' do
    its(:previous_title) { should eq 'previous' }
    its(:previous_label) { should eq '&lt;prev' }
    its(:next_title) { should eq 'next' }
    its(:next_label) { should eq 'next&gt;' }
    its(:next_link) { should eq art_piece_tag_path(tag, :p => 1) }
    its(:previous_link) { should eq art_piece_tag_path(tag, :p => 0) }
  end

  context 'with page arguments' do
    let(:page_args) { {:arg => 's'} }

    its(:next_link) { should eq art_piece_tag_path(tag, :p => 1, :arg => 's') }
    its(:previous_link) { should eq art_piece_tag_path(tag, :p => 0, :arg => 's') }
  end

end
