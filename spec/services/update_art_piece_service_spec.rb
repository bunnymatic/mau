require 'rails_helper'

describe UpdateArtPieceService do
  let(:artist) { create :artist, :active, :with_tagged_art }
  let(:art) { artist.reload.art_pieces.first }
  let(:existing_tag) { art.tags.first }
  let(:params) { {} }
  subject(:service) { described_class.new(art, params) }

  before do
    allow(BryantStreetStudiosWebhook).to receive(:artist_updated)
  end

  context 'with params[:tags]' do
    let(:tag_params) { ['mytag', 'YourTag', 'MyTag', existing_tag.name] }
    let(:params) do
      {
        title: Faker::Lorem.words(number: 4).join(' '),
        tag_ids: tag_params,
      }
    end

    it 'updates an art piece' do
      expect { service.update_art_piece }.to change(ArtPiece, :count).by(0)
    end

    it 'creates new tags as needed' do
      existing_tag
      expect { service.update_art_piece }.to change(ArtPieceTag, :count).by(2)
    end

    it 'returns the art piece' do
      ap = service.update_art_piece
      expect(ap.valid?).to eq true
      expect(ap.tags.map(&:name)).to match_array ['mytag', 'yourtag', existing_tag.name]
    end

    it 'posts a changed artist webhook to bryant street studios' do
      service.update_art_piece
      expect(BryantStreetStudiosWebhook).to have_received(:artist_updated).with(artist.id)
    end
  end
end
