# frozen_string_literal: true
require 'rails_helper'

describe ThumbnailBrowserPresenter do
  include PresenterSpecHelpers

  let(:artist) { FactoryGirl.create(:artist, :with_art) }
  let(:art_pieces) { artist.art_pieces }
  let(:art_piece) { artist.art_pieces[1] }
  subject(:presenter) { ThumbnailBrowserPresenter.new(artist, art_piece) }

  describe '#pieces' do
    subject { super().pieces }

    it 'has artist.art_pieces.count pieces' do
      expect(subject.size).to eq(artist.art_pieces.count)
    end
  end

  describe '#thumbs' do
    subject { super().thumbs }

    it 'has artist.art_pieces.count pieces' do
      expect(subject.size).to eq(artist.art_pieces.count)
    end
  end

  describe '#has_thumbs?' do
    subject { super().has_thumbs? }
    it { should eq(true) }
  end

  describe '#row_class' do
    subject { super().row_class }
    it { should eql 'rows1' }
  end

  describe '#thumbs_json' do
    subject { super().thumbs_json }
    it { should be_a_kind_of String }
  end

  describe '#next_img' do
    subject { super().next_img }
    it { should eql artist.art_pieces[2].id }
  end

  describe '#prev_img' do
    subject { super().prev_img }
    it { should eql artist.art_pieces[0].id }
  end

  describe '#current_index' do
    subject { super().current_index }
    it { should eql 1 }
  end
end
