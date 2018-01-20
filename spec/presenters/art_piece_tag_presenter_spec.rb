# frozen_string_literal: true

require 'rails_helper'

describe ArtPieceTagPresenter do
  include PresenterSpecHelpers

  let(:artist) { FactoryBot.create :artist, :active, :with_tagged_art, number_of_art_pieces: 4 }
  let(:artist2) do
    a = FactoryBot.create :artist, :active, :with_art, number_of_art_pieces: 4
    a.art_pieces.each do |ap|
      ap.tags = ap.tags + artist.art_pieces.map(&:tags).compact.uniq.first
      ap.save
    end
  end
  let!(:artists) { [artist, artist2] }
  let(:tag) { artist.art_pieces.map(&:tags).flatten.compact.first }
  let(:art) { tag.art_piece }
  let(:mode) { 'p' }

  subject(:presenter) { ArtPieceTagPresenter.new(tag, mode) }

  describe '#art_pieces' do
    it 'has 5 art_pieces' do
      expect(subject.art_pieces.size).to eq(5)
    end
  end
  it 'sorts by updated at' do
    expect(subject.art_pieces.map { |p| p.updated_at.to_i }).to be_monotonically_decreasing
  end

  context 'when showing only by artist' do
    let(:mode) { 'a' }

    describe '#art_pieces' do
      it 'has 2 art_pieces' do
        expect(subject.art_pieces.size).to eq(2)
      end
    end
  end

  context 'with inactive artists in the system' do
    before do
      artists.first.suspend!
    end
    it 'shows art only from active artists' do
      expect(subject.art_pieces.map(&:artist).flatten.uniq.map.all?(&:active?)).to eq(true)
    end
  end
end
