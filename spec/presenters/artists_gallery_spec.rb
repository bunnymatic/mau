# frozen_string_literal: true
require 'rails_helper'

describe ArtistsGallery do
  include PresenterSpecHelpers

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) do
    [
      create(:artist, :with_art, firstname: 'a', lastname: 'Abby'),
      create(:artist, :with_art, firstname: 'b', lastname: 'Asinine'),
      create(:artist, :with_art, firstname: 'c', lastname: 'Atkins'),
      create(:artist, :with_art, firstname: 'zed', lastname: 'bab'),
      create(:artist, :with_art, firstname: 'zoo', lastname: 'cab'),
      create(:artist, :with_art, firstname: 'zap', lastname: ''),
      create(:artist, firstname: 'z', lastname: 'Arnold'),
      create(:artist, firstname: 'a', lastname: 'Bored')
    ]
  end
  let(:showing_artists) { artists.first(per_page) }
  let(:os_only) { false }
  let(:letter) { 'A' }
  let(:ordering) { nil }
  subject(:presenter) { ArtistsGallery.new(os_only, letter, ordering, current_page, per_page) }

  before do
    fix_leaky_fixtures
    artists
  end

  describe '#current_page' do
    subject { super().current_page }
    it { should eql current_page }
  end

  describe '#per_page' do
    subject { super().per_page }
    it { should eql per_page }
  end

  describe '#empty_message' do
    subject { super().empty_message }
    it { should include "couldn't find any artists" }
  end

  it 'shows no artists without a representative piece' do
    with_art, without_art = presenter.items.partition{|a| a.representative_piece}
    expect(without_art).to be_empty
    expect(with_art.size).to eq(1)
    expect(with_art.first.lastname).to eql 'Atkins'
  end

  it 'artists include only those with representative pieces sorted by name' do
    expect(subject.artists.map(&:artist)).to eql artists.first(3)
  end

  context 'with open studios set true' do
    let(:os_only) { true }

    describe '#empty_message' do
      subject { super().empty_message }
      it { should include "no one with that name has signed up" }
    end
  end

  context 'when sorted by first name' do
    let(:ordering) { :firstname }
    let(:letter) { 'z' }
    it 'artists include only those with representative pieces sorted by name' do
      expect(subject.artists.map(&:artist)).to eql artists[3..5]
    end
  end
end
