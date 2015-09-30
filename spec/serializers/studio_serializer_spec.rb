require 'spec_helper'

describe StudioSerializer do
  let(:studio) { create :studio }
  let(:serializer) { StudioSerializer.new(studio) }
  describe 'to_json' do
    [:created_at, :updated_at].each do |field|
      it "does not include #{field} by default" do
        JSON.parse(serializer.to_json)['studio'].should_not have_key field.to_s
      end
    end
    it "includes name" do
      JSON.parse(serializer.to_json)['studio']['name'].should eql studio.name
    end
    it 'includes the street address' do
      JSON.parse(serializer.to_json)['studio']['street_address'].should eql studio.address_hash.parsed.street
    end
    it 'includes the city' do
      JSON.parse(serializer.to_json)['studio']['city'].should eql studio.address_hash.parsed.city
    end
    it 'includes a url for the map' do
      JSON.parse(serializer.to_json)['studio']['map_url'].should eql studio.map_link
    end

  end
end
