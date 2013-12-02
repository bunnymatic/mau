require 'spec_helper'

describe ArtPiecePresenter do

  include PresenterSpecHelpers

  let(:artist) { FactoryGirl.create(:artist, :with_art, :activated) }
  let(:art_piece) { artist.art_pieces.first }
  let(:tags) { FactoryGirl.create_list(:art_piece_tag, 2) }
  let(:tag) { FactoryGirl.build(:art_piece_tag) }
  subject(:presenter) { ArtPiecePresenter.new(mock_view_context, art_piece) }

  its(:favorites_count) { should be_nil }
  its(:has_tags?) { should be_false }
  its(:tags) { should be_empty }
  its(:has_year?) { should be_true }
  its(:has_dimensions?) { should be_true }
  its(:display_dimensions) { should eql art_piece.dimensions }
  its(:image_dimensions) { should eql art_piece.compute_dimensions }
  its(:width) { should eql art_piece.compute_dimensions[:medium].first }
  its(:zoomed_width) { should eql art_piece.compute_dimensions[:large].first }
  its(:zoomed_height) { should eql art_piece.compute_dimensions[:large].last }
  its(:zoomed) { should eql art_piece.get_path('large') }

  context 'with favorites' do
    before do
      favorites_mock = double(:mock_favorites_relation)
      favorites_mock.stub(:where => [1,2])
      Favorite.stub(:art_pieces => favorites_mock)
    end
    its(:favorites_count) { should eql 2 }
  end

  context 'with a bad year' do
    before do
      ArtPiece.any_instance.stub(:year => 1000)
    end
    its(:has_year?) { should be_false }
  end

  context 'with tags' do
    before do
      ArtPiece.any_instance.stub(:uniq_tags).and_return(tags)
    end
    its(:has_tags?) { should be_true }
    its(:tags) { should eql tags }
  end


end
