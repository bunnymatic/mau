require 'rails_helper'

describe ArtistsGallery do
  include PresenterSpecHelpers

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) do
    [
      create(:artist, :with_art, firstname: 'zed', lastname: 'bab'),
      create(:artist, :with_art, firstname: 'a', lastname: 'Abby'),
      create(:artist, :with_art, firstname: 'c', lastname: 'Atkins'),
      create(:artist, :with_art, firstname: 'zoo', lastname: 'cab'),
      create(:artist, :with_art, firstname: 'b', lastname: 'Asinine'),
      create(:artist, :with_art, firstname: 'zap', lastname: ''),
      create(:artist, firstname: 'z', lastname: 'Arnold'),
      create(:artist, firstname: 'a', lastname: 'Bored'),
    ]
  end
  let(:showing_artists) { artists.first(per_page) }
  let(:os_only) { false }
  let(:letter) { 'A' }
  let(:ordering) { nil }
  subject(:presenter) { ArtistsGallery.new(os_only:, letter:, ordering:, current_page:, per_page:) }

  before do
    artists
  end

  it 'sets up pagination and an empty_message' do
    expect(presenter.current_page).to eq current_page
    expect(presenter.per_page).to eq per_page
    expect(presenter.empty_message).to include "couldn't find any artists"
  end

  it 'artists include only those with representative pieces sorted by name' do
    with_art, without_art = presenter.items.partition(&:representative_piece)
    expect(without_art).to be_empty
    expect(with_art.size).to eq(1)
    expect(with_art.first.lastname).to eql 'Atkins'

    expect(presenter.artists.map(&:artist)).to eql [artists[1], artists[4], artists[2]]
  end

  context 'with open studios set true' do
    let(:os_only) { true }
    before do
      create(:open_studios_event)
    end

    describe '#empty_message' do
      its(:empty_message) { is_expected.to include 'no one with that name has signed up' }
    end
  end

  context 'when sorted by first name' do
    let(:ordering) { :firstname }
    let(:letter) { 'z' }
    it 'artists include only those with representative pieces sorted by name' do
      [artists[0], artists[3], artists[5]].map(&:firstname)
      expect(subject.artists.map(&:artist)).to eql [artists[0], artists[3], artists[5]]
    end
  end

  describe '.letters' do
    it 'returns letters in order for last name' do
      expect(described_class.letters('lastname')).to eq ['a', 'b', 'c', '&hellip;']
    end

    it 'returns letters in order for first name' do
      expect(described_class.letters('firstname')).to eq %w[a b c z]
    end
  end
end
