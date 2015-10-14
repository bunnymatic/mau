require 'spec_helper'

describe StudioSerializer do
  let(:studio) { create :studio, :with_artists }
  let(:serializer) { StudioSerializer.new(studio) }
  let(:parsed) { JSON.parse(serializer.to_json) }
  describe 'to_json' do
    [:created_at, :updated_at].each do |field|
      it "does not include #{field} by default" do
        parsed['studio'].should_not have_key field.to_s
      end
    end
    it "includes name" do
      parsed['studio']['name'].should eql studio.name
    end
    it 'includes the street address' do
      parsed['studio']['street_address'].should eql studio.address_hash.parsed.street
    end
    it 'includes the city' do
      parsed['studio']['city'].should eql studio.address_hash.parsed.city
    end
    it 'includes a url for the map' do
      parsed['studio']['map_url'].should eql studio.map_link
    end

    it "includes only artist ids" do
      expect(parsed['studio']['artists'].map(&:keys).flatten.uniq).to eql ['id']
    end

  end
end
