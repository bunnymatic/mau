require 'rails_helper'

describe ArtPiecePresenter do
  include PresenterSpecHelpers

  let(:artist) { FactoryBot.create(:artist, :with_art, :active) }
  let(:art_piece) { artist.art_pieces.first }
  let(:tags) { FactoryBot.create_list(:art_piece_tag, 2) }
  let(:tag) { FactoryBot.build(:art_piece_tag) }
  subject(:presenter) { ArtPiecePresenter.new(art_piece) }

  its(:favorites_count) { is_expected.to be_nil }
  its(:tags?) { is_expected.to be_falsy }
  its(:tags) { is_expected.to be_empty }
  its(:year?) { is_expected.to be_truthy }
  its(:year) { is_expected.to eql art_piece.year }

  describe '#path' do
    before do
      allow(art_piece).to receive(:attached_photo).and_return('the-file')
    end

    it 'returns the right size if given an argument' do
      presenter.path(:small)
      expect(art_piece).to have_received(:attached_photo).with(:small)
      presenter.path(:large)
      expect(art_piece).to have_received(:attached_photo).with(:large)
    end
  end

  context 'with favorites' do
    before do
      favorites_mock = double(:mock_favorites_relation, where: [1, 2])
      allow(Favorite).to receive(:art_pieces).and_return(favorites_mock)
    end

    its(:favorites_count) { is_expected.to eql(2) }
  end

  context 'with a bad year' do
    before do
      allow(art_piece).to receive(:year).and_return(1000)
    end

    its(:year?) { is_expected.to be_falsy }
  end

  context 'with tags' do
    before do
      allow_any_instance_of(ArtPiece).to receive(:uniq_tags).and_return(tags)
    end

    its(:tags?) { is_expected.to be_truthy }
    its(:tags) { is_expected.to eql tags }
  end
end
