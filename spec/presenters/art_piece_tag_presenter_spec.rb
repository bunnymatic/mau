require 'spec_helper'

describe ArtPieceTagPresenter do

  let(:joiner) { ArtPiecesTag.first }
  let(:tag) { joiner.art_piece_tag }
  let(:art) { joiner.art_piece }
  let(:mode) { 'p' }

  subject(:presenter) { ArtPieceTagPresenter.new(tag,mode) }

  its(:art_pieces) { should have(5).art_pieces }
  it 'only shows art from active artists' do
    subject.art_pieces.map{|ap| ap.artist.is_active? }.uniq.should eql [true]
  end
  it 'sorts by updated at' do
    subject.art_pieces.map{|p| p.updated_at.to_i}.should be_monotonically_decreasing
  end

  context 'when showing only by artist' do
    let(:mode) { 'a' }
    its(:art_pieces) { should have(2).art_pieces }
  end

end
