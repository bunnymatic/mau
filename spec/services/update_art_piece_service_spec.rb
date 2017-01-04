require 'rails_helper'

describe UpdateArtPieceService do

  let(:artist) { create :artist, :active, :with_tagged_art }
  let!(:art) { artist.art_pieces.first }
  let(:existing_tag) { art.tags.first }
  let(:params) { {} }
  subject (:service) { described_class.new(art, params) }

  context "with params[:tags]" do
    let(:tag_params) { ['mytag', 'YourTag', 'MyTag', existing_tag.name].join(", ") }
    let(:params) {
      {
        title: Faker::Lorem.words(4).join(" "),
        tags: tag_params
      }
    }

    it "updates an art piece" do
      expect{ service.update_art_piece }.to change(ArtPiece, :count).by(0)
    end

    it "creates new tags as needed" do
      existing_tag
      expect{ service.update_art_piece }.to change(ArtPieceTag, :count).by(2)
    end

    it "returns the art piece" do
      ap = service.update_art_piece
      expect(ap.valid?).to eq true
      expect(ap.tags.map(&:name)).to match_array ['mytag', 'yourtag', existing_tag.name]
    end

  end

end
