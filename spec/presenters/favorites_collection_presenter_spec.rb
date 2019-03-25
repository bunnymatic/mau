# frozen_string_literal: true

require 'rails_helper'

describe FavoritesCollectionPresenter do
  let(:artist) { instance_double(Artist) }
  let(:current_user) { nil }
  let(:favorite_artists) { [] }
  let(:favorite_art_pieces) { [] }
  subject(:presenter) { FavoritesCollectionPresenter.new(artist, current_user) }

  before do
    allow(artist).to receive_message_chain(:favorites, :artists).and_return(favorite_artists)
    allow(artist).to receive_message_chain(:favorites, :art_pieces).and_return(favorite_art_pieces)
  end

  context 'with favorites' do
    let(:favorite_artists) do
      [
        instance_double(Artist, representative_piece: instance_double(ArtPiece), active?: true),
        instance_double(Artist, representative_piece: instance_double(ArtPiece), active?: true),
        instance_double(Artist, representative_piece: instance_double(ArtPiece), active?: false),
      ].map { |artist| instance_double(Favorite, to_obj: artist, favoritable: artist) }
    end
    let(:favorite_art_pieces) do
      [
        instance_double(ArtPiece, artist: instance_double(Artist, active?: true)),
        instance_double(ArtPiece, artist: instance_double(Artist, active?: true)),
        instance_double(ArtPiece, artist: instance_double(Artist, active?: false)),
        instance_double(ArtPiece),
      ].map { |art| instance_double(Favorite, to_obj: art, favoritable: art) }
    end

    describe '#art_pieces' do
      it 'has 2 art_pieces' do
        expect(subject.art_pieces.size).to eq(2)
      end
    end

    describe '#artists' do
      it 'has 2 artists' do
        expect(subject.artists.size).to eq(2)
      end
    end

    context 'when the artists are not all active' do
      let(:favorite_artists) do
        [
          instance_double(Artist, representative_piece: instance_double(ArtPiece), active?: true),
          instance_double(Artist, representative_piece: instance_double(ArtPiece), active?: false),
        ].map { |artist| instance_double(Favorite, to_obj: artist, favoritable: artist) }
      end
      describe '#artists' do
        it 'has 1 artist' do
          expect(subject.artists.size).to eq(1)
        end
      end
    end
  end

  context 'when the artist has no favorites' do
    let(:favorite_artists) { [] }
    let(:favorite_art_pieces) { [] }
    describe '#art_pieces' do
      subject { super().art_pieces }
      it { is_expected.to be_empty }
    end

    describe '#artists' do
      subject { super().artists }
      it { is_expected.to be_empty }
    end

    describe '#empty_message' do
      subject { super().empty_message }
      it { is_expected.to match(/not favorited anything/) }
    end
  end

  context 'when the viewer is the artist' do
    let(:current_user) { artist }
    context 'and the artist has no favorites' do
      describe '#empty_message' do
        subject { super().empty_message }
        it { is_expected.to match(/Go find an artist/) }
      end
    end
  end
end
