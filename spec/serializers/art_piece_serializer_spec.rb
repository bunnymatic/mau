require 'rails_helper'

describe ArtPieceSerializer do
  let(:art_piece) { create(:art_piece, :with_tags) }
  let(:artist) { art_piece.artist }
  let(:parsed) { serialize(art_piece, described_class) }
  let(:parsed_art_piece) { parsed[:data][:attributes] }
  let(:relationships) { parsed[:data][:relationships] }

  include ActionView::Helpers::NumberHelper

  describe 'to_json' do
    it 'includes the fields we care about' do
      %i[title artist_id year image_urls artist_name price sold_at].each do |expected|
        expect(parsed_art_piece).to have_key expected
      end
    end

    it 'includes price and formatted price' do
      expect(parsed_art_piece[:price]).to eq art_piece.price
      expect(parsed_art_piece[:display_price]).to eq number_to_currency(art_piece.price)
    end

    it 'includes paths to the images' do
      sizes = %i[large medium original small]
      files = parsed_art_piece[:image_urls]
      expect(files.keys.sort).to eql sizes
      sizes.each do |sz|
        expect(files[sz]).to include art_piece.photo.url(sz, timestamp: false)
      end
    end

    it 'includes the tags' do
      expect(relationships[:tags]).to be_present
    end
    it 'includes the artists name' do
      expect(parsed_art_piece[:artist_name]).to eql html_encode(art_piece.artist.full_name)
    end
    it 'includes the art piece title' do
      expect(parsed_art_piece[:title]).to eql art_piece.title
    end
    it 'includes the medium' do
      expect(relationships[:medium]).to be_present
    end
  end
end
