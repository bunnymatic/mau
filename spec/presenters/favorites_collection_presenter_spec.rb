# frozen_string_literal: true

require 'rails_helper'

describe FavoritesCollectionPresenter do
  let(:artists) { create_list(:artist, 4, :active, :with_art) + [create(:artist, :active)] }
  let(:artist) { artists.first }
  let(:art_piece_without_artist) { create(:art_piece) }
  let(:current_user) { nil }
  subject(:presenter) { FavoritesCollectionPresenter.new(artist.favorites, artist, current_user) }

  context 'with favorites' do
    before do
      create_favorite(artist, artists[1])
      create_favorite(artist, artists[2])
      create_favorite(artist, artists.last)

      create_favorite(artist, artists[2].art_pieces.first)
      create_favorite(artist, artists[3].art_pieces.first)
      create_favorite(artist, art_piece_without_artist)
      art_piece_without_artist.artist.suspend!
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
      before do
        artists[1].suspend!
      end

      describe '#artists' do
        it 'has 1 artist' do
          expect(subject.artists.size).to eq(1)
        end
      end
    end
  end

  context 'when the artist has no favorites' do
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
