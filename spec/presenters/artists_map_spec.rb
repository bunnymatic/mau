require 'spec_helper'

describe ArtistsMap do

  include PresenterSpecHelpers

  fixtures :users, :roles_users,  :roles, :artist_infos, :art_pieces,
    :studios, :media, :art_piece_tags, :art_pieces_tags, :cms_documents

  let(:os_only) { false }
  let(:ne_bounds) { Artist::BOUNDS['NE'] }
  let(:sw_bounds) { Artist::BOUNDS['SW'] }

  subject(:map) { ArtistsMap.new(mock_view_context, os_only) }

  its(:grouped_by_address) { should have(map.artists.select(&:has_address?).map(&:address).compact.uniq.count).keys }
  its('with_addresses.count') { should eql map.artists.select(&:has_address?).count }
  it 'sorts groups by the number of artists in each group' do
    expect(map.grouped_by_address_and_sorted.map{|entry| entry[1].length}).to be_monotonically_decreasing
  end

  context 'when os_only is true' do
    let(:os_only) { true }

    it 'includes artists in the mission' do
      map.with_addresses.each do |a|
        lat,lng = a.address_hash[:latlng]
        (sw_bounds[0] < lat && lat < ne_bounds[0]).should be_true, "Latitude #{lat} is not within bounds"
        (sw_bounds[1] < lng && lng < ne_bounds[1]).should be_true ,"Longitude #{lng} is not within bounds"
      end
    end
  end
end
