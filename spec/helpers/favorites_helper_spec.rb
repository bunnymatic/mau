# frozen_string_literal: true
require 'rails_helper'

describe FavoritesHelper do
  describe '#get_favorite_image_and_path' do
    let(:favorite) { create :art_piece }
    before do
      @img,@path = helper.get_favorite_image_and_path(favorite)
    end
    context 'for an art piece' do
      it 'returns no image and the path to the art piece' do
      end
    end
    context 'for an artist' do
      context 'who has an image' do
        let(:favorite) { create :artist }
        it 'returns the default user image and the path to the artist' do
          expect(@img).to eq favorite.get_profile_image(:small)
          expect(@path).to eq user_path(favorite)
        end
      end
    end
  end
end
