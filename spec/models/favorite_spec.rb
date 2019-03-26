# frozen_string_literal: true

require 'rails_helper'

describe Favorite, 'named scopes' do
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:jesse) { FactoryBot.create(:artist, :with_studio, :with_art) }
  let(:anna) { FactoryBot.create(:artist, :with_studio, :with_art) }
  let(:artist) { FactoryBot.create(:artist, :with_studio, :with_art) }

  it 'does not allow duplicates' do
    create_favorite fan, jesse
    f = Favorite.new user_id: fan.id, favoritable_type: jesse.class.name, favoritable_id: jesse.id
    expect(f).to_not be_valid
    expect(f.errors[:user]).to have(1).item
  end

  it 'destroys unused ones as necessary' do
    f = Favorite.create(favoritable_type: 'Artist', favoritable_id: 55_555)
    f.to_obj
    expect(Favorite.where(favoritable_type: 'Artist', favoritable_id: 55_555)).to be_empty
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
        expect(f.artist?).to eq(true)
        expect(f.art_piece?).to eq false
      end

      expect(Favorite.art_pieces.count).to be > 0
      Favorite.art_pieces.all.each do |f|
        expect(f.artist?).to eq false
        expect(f.art_piece?).to eq(true)
      end
    end
  end
end
