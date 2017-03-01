# frozen_string_literal: true
require 'rails_helper'

describe FavoritesHelper do
  describe '#get_favorite_image_and_path' do
    let(:favorite) { create :art_piece }
    let(:image_and_path) { helper.get_favorite_image_and_path(favorite) }
    let(:img) { image_and_path[0] }
    let(:path) { image_and_path[1] }

    context 'for an art piece' do
      it 'returns the small iamge' do
        expect(img).to match(%r{art_pieces\/photos\/.*\/small\/new-art-piece.jpg})
      end
      it 'returns the path to the art picee' do
        expect(path).to eq art_piece_path(favorite)
      end
    end
    context 'for an artist' do
      context 'who has does not have a profile image' do
        let(:favorite) { create :artist }
        it 'returns the default user image' do
          expect(img).to match(/default_user-.*\.svg/)
        end
        it 'returns the path to the artist' do
          expect(path).to eq user_path(favorite)
        end
      end
      context 'who has a profile image' do
        let(:favorite) { create :artist, :with_photo }
        it 'returns the small profile image' do
          expect(img).to match(%r{artists\/photos\/.*\/small\/new-profile.jpg})
        end
        it 'returns the path to the artist' do
          expect(path).to eq user_path(favorite)
        end
      end
    end
  end
end
