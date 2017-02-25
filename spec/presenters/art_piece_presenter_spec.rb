# frozen_string_literal: true
require 'rails_helper'

describe ArtPiecePresenter do
  include PresenterSpecHelpers

  let(:artist) { FactoryGirl.create(:artist, :with_art, :active) }
  let(:art_piece) { artist.art_pieces.first }
  let(:tags) { FactoryGirl.create_list(:art_piece_tag, 2) }
  let(:tag) { FactoryGirl.build(:art_piece_tag) }
  subject(:presenter) { ArtPiecePresenter.new(art_piece) }

  describe '#favorites_count' do
    subject { super().favorites_count }
    it { should be_nil }
  end

  describe '#has_tags?' do
    subject { super().has_tags? }
    it { should eq(false) }
  end

  describe '#tags' do
    subject { super().tags }
    it { should be_empty }
  end

  describe '#has_year?' do
    subject { super().has_year? }
    it { should eq(true) }
  end

  context 'with favorites' do
    before do
      favorites_mock = double(:mock_favorites_relation, where: [1,2])
      allow(Favorite).to receive(:art_pieces).and_return(favorites_mock)
    end

    describe '#favorites_count' do
      subject { super().favorites_count }
      it { should eql 2 }
    end
  end

  context 'with a bad year' do
    before do
      allow(art_piece).to receive(:year).and_return(1000)
    end

    describe '#has_year?' do
      subject { super().has_year? }
      it { should eq(false) }
    end
  end

  context 'with tags' do
    before do
      allow_any_instance_of(ArtPiece).to receive(:uniq_tags).and_return(tags)
    end

    describe '#has_tags?' do
      subject { super().has_tags? }
      it { should eq(true) }
    end

    describe '#tags' do
      subject { super().tags }
      it { should eql tags }
    end
  end
end
