# frozen_string_literal: true
require 'rails_helper'

describe ThumbnailBrowserPresenter do
  include PresenterSpecHelpers

  let(:artist) { FactoryBot.create(:artist, :with_art, number_of_art_pieces: 3) }
  let(:art_pieces) { artist.art_pieces }
  let(:art_piece) { artist.art_pieces[1] }
  subject(:presenter) { ThumbnailBrowserPresenter.new(artist, art_piece) }

  its(:thumbs?) { is_expected.to be_truthy }

  describe '#pieces' do
    it 'has artist.art_pieces.count pieces' do
      expect(subject.pieces.size).to eq(artist.art_pieces.count)
    end
  end

  describe '#thumbs' do
    it 'has artist.art_pieces.count pieces' do
      expect(subject.thumbs.size).to eq(artist.art_pieces.count)
    end
  end

  its(:row_class) { is_expected.to eql('rows1') }

  its(:next_img) { is_expected.to eql(artist.art_pieces[2].id) }

  its(:prev_img) { is_expected.to eql(artist.art_pieces[0].id) }

  its(:current_index) { is_expected.to eql(1) }
end
