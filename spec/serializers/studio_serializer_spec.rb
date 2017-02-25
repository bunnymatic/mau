# frozen_string_literal: true
require 'rails_helper'

describe StudioSerializer do
  let(:studio) { create :studio, :with_artists }
  let(:serializer) { ActiveModelSerializers::SerializableResource.new(studio) }
  let(:parsed) { JSON.parse(serializer.to_json) }
  describe 'to_json' do
    [:created_at, :updated_at].each do |field|
      it "does not include #{field} by default" do
        expect(parsed['studio']).not_to have_key field.to_s
      end
    end
    it 'includes name' do
      expect(parsed['studio']['name']).to eql studio.name
    end
    it 'includes the street address' do
      expect(parsed['studio']['street_address']).to eql studio.address.street
    end
    it 'includes the city' do
      expect(parsed['studio']['city']).to eql studio.address.city
    end
    it 'includes a url for the map' do
      expect(parsed['studio']['map_url']).to eql studio.map_link
    end

    it 'includes trimmed version of artists' do
      expect(parsed['studio']['artists'].map(&:keys).flatten.uniq).to match_array(%w(id firstname lastname slug full_name))
    end
  end
end
