require 'spec_helper'

describe ArtistsMap do

  include PresenterSpecHelpers

  let(:os_only) { false }
  let(:ne_bounds) { Artist::BOUNDS['NE'] }
  let(:sw_bounds) { Artist::BOUNDS['SW'] }

  subject(:map) { ArtistsMap.new(os_only) }

  context 'when os_only is false' do
    describe '#grouped_by_address' do
      subject { super().grouped_by_address }

      it 'has map.artists.select(&:has_address?).map(&:address).compact.uniq.count keys' do
        expect(subject.keys.size).to eq(map.artists.select(&:has_address?).map(&:address).compact.uniq.count)
      end
    end

    describe '#with_addresses' do
      subject { super().with_addresses }
      describe '#count' do
        subject { super().count }
        it { should eql map.artists.select(&:has_address?).count }
      end
    end

    describe "#grouped_by_address_and_sorted" do
      it "sorts groups by the number of artists in each group" do
        expect(map.grouped_by_address_and_sorted.map{|entry| entry[1].length}).to be_monotonically_decreasing
      end
      it 'returns only artists who are in the mission' do
        expect(map.grouped_by_address.values.flatten.all? &:in_the_mission?).to eq(true)
      end
    end
  end

  context 'when os_only is true' do
    let(:os_only) { true }

    it 'includes artists in the mission' do
      map.with_addresses.each do |a|
        lat,lng = a.address_hash[:latlng]
        expect(sw_bounds[0] < lat && lat < ne_bounds[0]).to eq(true), "Latitude #{lat} is not within bounds"
        expect(sw_bounds[1] < lng && lng < ne_bounds[1]).to eq(true) ,"Longitude #{lng} is not within bounds"
      end
    end
  end
end
