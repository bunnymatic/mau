require 'spec_helper'

describe ArtPieceTagPresenter do

  include PresenterSpecHelpers

  let(:artist) { FactoryGirl.create :artist, :active, :with_tagged_art, number_of_art_pieces: 4 }
  let(:artist2) do
    a = FactoryGirl.create :artist, :active, :with_art, number_of_art_pieces: 4
    a.art_pieces.each do |ap|
      ap.tags = ap.tags + artist.art_pieces.map(&:tags).compact.uniq.first
      ap.save
    end
  end
  let!(:artists) { [artist, artist2] }
  let(:tag) { artist.art_pieces.map(&:tags).flatten.compact.first }
  let(:art) { tag.art_piece }
  let(:mode) { 'p' }

  subject(:presenter) { ArtPieceTagPresenter.new(tag,mode) }

  its(:art_pieces) { should have(5).art_pieces }
  it 'only shows art from active artists' do
    subject.art_pieces.map{|ap| ap.artist.is_active? }.uniq.should eql [true]
  end
  it 'sorts by updated at' do
    subject.art_pieces.map{|p| p.art_piece.updated_at.to_i}.should be_monotonically_decreasing
  end

  context 'when showing only by artist' do
    let(:mode) { 'a' }
    its(:art_pieces) { should have(2).art_pieces }
  end

end
