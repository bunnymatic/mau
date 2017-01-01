require 'rails_helper'

describe CreateArtPieceService do

  let(:artist) { create :artist, :active }
  let(:existing_tag) { create :art_piece_tag, name: 'existing tag' }
  let(:params) { {} }
  subject (:service) { described_class.new(artist, params) }

  context "with params[:tags]" do
    let(:tag_params) { ['mytag', 'YourTag', 'MyTag', existing_tag.name].join(", ") }
    let(:params) {
      attributes_for(:art_piece).merge({tags: tag_params})
    }

    it "creates an art piece" do
      expect{ service.create_art_piece }.to change(ArtPiece, :count).by(1)
    end

    it "creates new tags as needed" do
      existing_tag
      expect{ service.create_art_piece }.to change(ArtPieceTag, :count).by(2)
    end

    it "returns the art piece" do
      ap = service.create_art_piece
      expect(ap.valid?).to eq true
      expect(ap.tags.map(&:name)).to match_array ['mytag', 'yourtag', existing_tag.name]
    end

  end

  context "with params[:tag_ids]" do
    let(:tag_params) { [ '', 'mytag', 'mytag', 'YourTag', 'MyTag', existing_tag.name] }
    let(:params) {
      attributes_for(:art_piece).merge({tag_ids: tag_params})
    }

    it "creates an art piece" do
      expect{ service.create_art_piece }.to change(ArtPiece, :count).by(1)
    end

    it "creates new tags as needed" do
      existing_tag
      expect{ service.create_art_piece }.to change(ArtPieceTag, :count).by(2)
    end

    it "returns the art piece" do
      ap = service.create_art_piece
      expect(ap.valid?).to eq true
      expect(ap.tags.map(&:name)).to match_array ['mytag', 'yourtag', existing_tag.name]
    end

  end

end
