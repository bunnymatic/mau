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

  describe '#by_artists?' do
    subject { super().by_artists? }
    it { should eq false }
  end

  describe '#by_pieces?' do
    subject { super().by_pieces? }
    it { should eq(true) }
  end

  describe '#all_art_pieces' do
    it 'has select_medium.art_pieces.count art_pieces' do
      expect(subject.all_art_pieces.size).to eq(select_medium.art_pieces.count)
    end
  end

  describe '#paginator' do
    subject { super().paginator }
    describe '#items' do
      it 'has 2 items' do
        expect(subject.items.size).to eq(2)
      end
    end
  end

  describe '#paginator' do
    subject { super().paginator }
    it { should be_a_kind_of MediumPagination }
  end

  describe '#paginator' do
    subject { super().paginator }
    describe '#per_page' do
      subject { super().per_page }
      it { should eql per_page }
    end
  end

  describe '#paginator' do
    subject { super().paginator }
    describe '#current_page' do
      subject { super().current_page }
      it { should eql page }
    end
  end

  context 'with inactive artists in the system' do
    before do
      artists.first.suspend!
    end
    it 'shows art only from active artists' do
      expect(art_pieces.map(&:artist).flatten.uniq.map.all?(&:active?)).to eq(true)
    end
  end
end
