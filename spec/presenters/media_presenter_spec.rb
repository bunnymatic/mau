# frozen_string_literal: true

require 'rails_helper'

describe MediaPresenter do
  include PresenterSpecHelpers

  let(:media) { FactoryBot.create_list(:medium, 4) }
  let(:artists) { FactoryBot.create_list(:artist, 5, :with_art) }
  let(:art_pieces) do
    pieces = artists.map(&:art_pieces).flatten
    pieces.each { |ap| ap.update(medium: select_medium) }
  end
  let(:page) { 1 }
  let(:mode) { nil }
  let(:per_page) { 2 }
  let(:select_medium) { media.last }

  subject(:presenter) { MediaPresenter.new(select_medium, page, mode, per_page) }

  it 'returns by pieces by default' do
    expect(presenter.by_artists?).to eq false
    expect(presenter.by_pieces?).to eq true
  end

  describe '#all_art_pieces' do
    before do
      art_pieces
    end
    it 'has select_medium.art_pieces.count art_pieces' do
      expect(subject.all_art_pieces.size).to eq(select_medium.art_pieces.count)
    end
  end

  describe '#paginator' do
    before do
      art_pieces
    end
    subject { presenter.paginator }
    it 'has 2 items' do
      expect(subject).to be_a_kind_of MediumPagination
      expect(subject.items).to have(2).items
      expect(subject.per_page).to eq per_page
      expect(subject.current_page).to eq page
    end
  end

  context 'with inactive artists in the system' do
    before do
      art_pieces
      artists.first.suspend!
    end
    it 'shows art only from active artists' do
      expect(presenter.all_art_pieces.map(&:artist).flatten.uniq.map.all?(&:active?)).to eq(true)
    end
  end
end
