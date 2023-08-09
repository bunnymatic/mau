require 'rails_helper'

describe ArtistsMap do
  include PresenterSpecHelpers

  let(:os_only) { false }
  let(:ne_bounds) { MissionBoundaries::BOUNDS['NE'] }
  let(:sw_bounds) { MissionBoudnaries::BOUNDS['SW'] }

  subject(:map) { ArtistsMap.new(os_only:) }
  let(:artists) do
    [
      create(:artist, :active, :with_art, :in_the_mission),
      create(:artist, :active, :with_art, :in_the_mission),
    ]
  end
  before do
    artists
  end

  describe '.map_data' do
    it 'constructs map data for the artists' do
      map_data = map.map_data
      expect(map_data).to have(2).items
      expected_data = artists.map do |a|
        {
          lat: a.address.lat,
          lng: a.address.lng,
          artistId: a.id,
          artistName: a.full_name,
          infowindow: ArtistPresenter.new(a).map_info,
        }
      end
      expect(map_data).to match_array expected_data
    end
  end

  context 'when os_only is false' do
    describe '#grouped_by_address' do
      it 'returns artists grouped by address' do
        expected = map.artists.filter_map do |a|
          a.address.to_s if a.address.present?
        end.uniq
        expect(subject.grouped_by_address.size).to eq(expected.count)
      end
    end

    describe '#with_addresses' do
      it 'returns all artists with addresses' do
        expect(subject.with_addresses.count).to eq(map.artists.count { |a| a.address.present? })
      end
    end

    describe '#grouped_by_address_and_sorted' do
      it 'sorts groups by the number of artists in each group' do
        expect(map.grouped_by_address_and_sorted.map { |entry| entry[1].length }).to be_monotonically_decreasing
      end
      it 'returns only artists who are in the mission' do
        expect(map.grouped_by_address.values.flatten.all?(&:in_the_mission?)).to eq(true)
      end
    end
  end

  context 'when os_only is true' do
    let(:os_only) { true }
    before do
      create(:open_studios_event)
    end
    it 'includes artists in the mission' do
      map.with_addresses.each do |a|
        lat = a.address.lat
        lng = a.address.lng
        expect(sw_bounds[0] < lat && lat < ne_bounds[0]).to eq(true), "Latitude #{lat} is not within bounds"
        expect(sw_bounds[1] < lng && lng < ne_bounds[1]).to eq(true), "Longitude #{lng} is not within bounds"
      end
    end
  end
end
