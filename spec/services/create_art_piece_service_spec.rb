# frozen_string_literal: true
require 'rails_helper'

describe CreateArtPieceService do
  let(:artist) { create :artist, :active }
  let(:existing_tag) { create :art_piece_tag, name: 'existing tag' }
  let(:params) { {} }
  subject (:service) { described_class.new(artist, params) }

  context 'with params[:tags]' do
    let(:tag_params) { ['mytag', 'YourTag', 'MyTag', existing_tag.name].join(', ') }
    let(:params) do
      attributes_for(:art_piece).merge(tags: tag_params)
    end

    it 'creates an art piece' do
      expect { service.create_art_piece }.to change(ArtPiece, :count).by(1)
    end

    it 'creates new tags as needed' do
      existing_tag
      expect { service.create_art_piece }.to change(ArtPieceTag, :count).by(2)
    end

    it 'returns the art piece' do
      ap = service.create_art_piece
      expect(ap.valid?).to eq true
      expect(ap.tags.map(&:name)).to match_array ['mytag', 'yourtag', existing_tag.name]
    end
  end

  context 'with invalid data' do
    let(:tag_params) { ['supertag', existing_tag.name].join(', ') }
    let(:params) do
      attrs = attributes_for(:art_piece).merge(tags: tag_params)
      attrs.delete :title
      attrs.delete :photo_file_name
      attrs
    end

    it 'returns the art piece with errors' do
      ap = service.create_art_piece
      expect(ap).to be_present
      expect(ap.errors).to have_at_least(1).error
    end

    it 'does not preserve tags' do
      ap = service.create_art_piece
      expect(ap.tags).to be_empty
    end
  end
end
