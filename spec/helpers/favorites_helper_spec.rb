require 'rails_helper'

describe FavoritesHelper do
  let(:favorite) { create :art_piece }
  describe '#draw_micro_favorite' do
    let(:options) { {} }
    subject(:micro) { helper.draw_micro_favorite(favorite, **options) }
    it 'returns an li with the favorite in there' do
      expect(micro).to have_css("li a[title='#{favorite.title}'] div[title='#{favorite.title}']")
      expect(micro).to have_css('[style*=background-image]')
    end
    context 'with options = {linkless: true}' do
      let(:options) { { linkless: true } }
      it 'does not include a link' do
        expect(micro).to have_css("li div[title='#{favorite.title}']")
        expect(micro).to_not have_css('li a div')
      end
    end
  end
  describe '#get_favorite_image_and_path' do
    let(:image_and_path) { helper.get_favorite_image_and_path(favorite) }
    let(:img) { image_and_path[0] }
    let(:path) { image_and_path[1] }

    context 'for an art piece' do
      it 'returns the path to the art picee' do
        expect(path).to eq art_piece_path(favorite)
      end
    end
    context 'for an artist' do
      context 'who has does not have a profile image' do
        let(:favorite) { create :artist }
        it 'returns the default user image' do
          expect(img).to match(/default_user.*\.svg/)
        end
        it 'returns the path to the artist' do
          expect(path).to eq user_path(favorite)
        end
      end
      context 'who has a profile image' do
        let(:favorite) { create :artist, :with_photo }
        it 'returns the path to the artist' do
          expect(path).to eq user_path(favorite)
        end
      end
    end
  end
end
