# frozen_string_literal: true

require 'rails_helper'

describe MediaPresenter do
  include PresenterSpecHelpers

  let(:media) { FactoryBot.create_list(:medium, 4) }
  let(:artists) { FactoryBot.create_list(:artist, 5, :with_art) }
  let!(:art_pieces) do
    pieces = artists.map(&:art_pieces).flatten
    pieces.each { |ap| ap.update(medium: select_medium) }
  end

  let(:page) { 1 }
  let(:mode) { nil }
  let(:per_page) { 2 }
  let(:select_medium) { media.last }

  subject(:presenter) { MediaPresenter.new(select_medium, page, mode, per_page) }

  its(:by_artists?) { is_expected.to eql false }
  its(:by_pieces?) { is_expected.to eql true }

  describe '#all_art_pieces' do
    it 'has select_medium.art_pieces.count art_pieces' do
      expect(subject.all_art_pieces.size).to eq(select_medium.art_pieces.count)
    end
  end

  describe '#paginator' do
    subject { super().paginator }
    it 'has 2 items' do
      expect(subject.items).to have(2).items
    end
    it { is_expected.to be_a_kind_of MediumPagination }
    its(:per_page) { is_expected.to eql per_page }
    its(:current_page) { is_expected.to eql page }
  end

  context 'with inactive artists in the system' do
    before do
      artists.first.suspend!
    end
    it 'shows art only from active artists' do
      expect(presenter.all_art_pieces.map(&:artist).flatten.uniq.map.all?(&:active?)).to eq(true)
    end
  end
end
