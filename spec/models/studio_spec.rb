require 'rails_helper'

describe Studio do
  subject(:studio) { FactoryBot.build(:studio) }

  it_behaves_like AddressMixin

  it { should validate_presence_of(:name) }

  it 'validates and cleans up the phone number on validate' do
    studio.phone = ' (415) 555 1212'
    expect(studio).to be_valid
    expect(studio.phone).to eq '4155551212'
  end

  it 'has a friendly id' do
    studio.save
    studio.reload
    expect(Studio.find(studio.id)).to be_present
    expect(Studio.find(studio.slug)).to be_present
  end

  describe 'address' do
    it 'responds to address' do
      expect(studio).to respond_to :address
    end
    it 'responds to full address' do
      expect(studio).to respond_to :full_address
    end
  end

  describe 'lat/lng updates' do
    let!(:studio) { create(:studio) }
    before do
      allow(Geokit::Geocoders::MultiGeocoder).to receive(:geocode)
    end
    it 'recomputes geocode if address changes' do
      studio.update(zipcode: 12_345)
      expect(Geokit::Geocoders::MultiGeocoder).to have_received(:geocode)
    end

    it 'does not recompute if lat/lng is the only change' do
      studio.update(lat: 1.234)
      expect(Geokit::Geocoders::MultiGeocoder).not_to have_received(:geocode)
    end
  end

  describe 'create' do
    let(:studio) { FactoryBot.build(:studio) }
    before do
      @s = Studio.new(FactoryBot.attributes_for(:studio))
    end
    it 'studio is valid' do
      expect(@s).to be_valid
    end
    it 'save triggers geocode' do
      s = Studio.new(FactoryBot.attributes_for(:studio))
      expect(s).to receive(:compute_geocode).at_least(:once).and_return([-37, 122])
      s.save!
    end
  end

  describe 'update' do
    before do
      studio.save
    end

    it 'triggers geocode given new street' do
      studio.street = '1891 Bryant St'
      expect(studio).to receive(:compute_geocode).at_least(:once).and_return([-37, 122])
      studio.save!
    end
  end

  describe 'by_position' do
    it 'sorts by position' do
      create_list(:studio, 3)
      expect(Studio.by_position.map(&:position)).to be_monotonically_increasing
    end
    it 'sorts by name if position is the same' do
      create(:studio, name: 'Zed', position: 5)
      create(:studio, name: 'zal', position: 5)
      create(:studio, name: 'Alp', position: 5)
      create(:studio, name: 'bor', position: 5)
      expect(Studio.by_position.map(&:name)).to eql %w[Alp bor zal Zed]
    end
  end
end
