require 'rails_helper'

describe StudioSerializer do
  let(:studio) { create :studio, :with_artists }
  let(:parsed) { serialize(studio, described_class) }
  let(:parsed_studio) { parsed[:data][:attributes] }

  describe 'to_json' do
    it 'has the right type' do
      expect(parsed[:data][:type]).to eql :studio
    end
    it 'has the right type' do
      expect(parsed[:data][:id]).to eql studio.id.to_s
    end
    it 'does not include date fields by default' do
      %i[created_at updated_at].each do |field|
        expect(parsed_studio).not_to have_key field
      end
    end

    it 'includes name, address, city and map url' do
      expect(parsed_studio[:name]).to eql studio.name
      expect(parsed_studio[:street_address]).to eql studio.address.street
      expect(parsed_studio[:city]).to eql studio.address.city
      expect(parsed_studio[:map_url]).to eql studio.map_link
    end
  end
end
