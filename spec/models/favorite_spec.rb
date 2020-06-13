# frozen_string_literal: true

require 'rails_helper'

describe Favorite, 'named scopes' do
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:jesse) { FactoryBot.create(:artist, :with_studio, :with_art) }
  let(:anna) { FactoryBot.create(:artist, :with_studio, :with_art) }
  let(:artist) { FactoryBot.create(:artist, :with_studio, :with_art) }

  it 'does not allow duplicates' do
    create_favorite fan, jesse
    f = Favorite.new owner_id: fan.id, favoritable_type: jesse.class.name, favoritable_id: jesse.id
    expect(f).to_not be_valid
    expect(f.errors[:owner]).to have(1).item
  end

  it 'requires valid favoritable object' do
    expect do
      Favorite.create!(owner_id: fan.id, favoritable_type: 'Artist', favoritable_id: 55_555)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'requires an owner' do
    expect do
      Favorite.create!(favoritable_type: 'Artist', favoritable_id: anna.id)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  describe 'scopes' do
    before do
      create_favorite fan, artist.art_pieces.first
      create_favorite fan, artist
      create_favorite fan, jesse
      create_favorite jesse, artist.art_pieces.first
      create_favorite jesse, artist
      create_favorite anna, jesse.art_pieces.last
    end
    it '#artists fetches artists and #art_pieces fetches art pieces' do
      expect(Favorite.artists.count).to be > 0
      Favorite.artists.all.each do |f|
        expect(f.favoritable).to be_a_kind_of(Artist)
      end

      expect(Favorite.art_pieces.count).to be > 0
      Favorite.art_pieces.all.each do |f|
        expect(f.favoritable).to be_a_kind_of(ArtPiece)
      end
    end
  end
end
