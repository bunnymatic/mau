require 'spec_helper'

shared_examples_for AddressMixin do

  let(:the_state) {
    Faker::Address.state
  }
  let(:base_attributes) {
    {
      :street => Faker::Address.street_name,
      :city => Faker::Address.city,
      :zip => Faker::Address.zip_code,
      :lat => rand(180) - 90,
      :lng => rand(360) - 180
    }
  }
  let(:with_state) {
    base_attributes.merge(:state => the_state)
  }
  let(:with_addr_state) {
    base_attributes.merge(:addr_state => the_state)
  }
  let(:with_address) {
    if (described_class.new.respond_to? :addr_state)
      described_class.new(with_addr_state)
    else
      described_class.new(with_state)
    end
  }
  let(:without_address) { described_class.new }

  describe '#full_address' do

    it 'builds a full address for maps' do
      with_address.full_address.should eql [base_attributes[:street], base_attributes[:city], the_state, base_attributes[:zip].to_i].join(", ")
    end
    it 'builds a full address for maps' do
      with_address.address.should eql [base_attributes[:street], base_attributes[:zip].to_i].join(" ")
    end

  end

  describe '#address' do
    it 'returns empty string if there is no street' do
      without_address.address.should eql ''
    end
    it 'returns empty string if there is no street' do
      without_address.full_address.should eql ''
    end
  end

  describe '#map_link' do
    it 'returns a google map link' do
      with_address.map_link.should match /maps\.google\.com\/maps\?q=#{URI.escape(base_attributes[:street])}/
    end
  end

  describe '#compute_geocode' do
    it 'calls Geocode with the full address' do
      Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with(with_address.full_address).and_return((double("GeocodeResult", :success =>true, :lat => with_address.lat, :lng => with_address.lng)))
      with_address.send(:compute_geocode).should eql [with_address.lat, with_address.lng]
    end
    it 'returns nothing on failure' do
      Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).and_return(double("GeocodeResult", :success =>false))
      with_address.send(:compute_geocode).should eql ['Unable to Geocode your address.']
    end
  end

end
