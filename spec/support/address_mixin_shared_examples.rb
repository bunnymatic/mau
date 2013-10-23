require 'spec_helper'

shared_examples_for AddressMixin do

  let(:address_attributes) {
    {
      :street => Faker::Address.street_name,
      :city => Faker::Address.city,
      :state => Faker::Address.state,
      :zip => Faker::Address.zip_code,
      :lat => rand(180) - 90,
      :lng => rand(360) - 180
    }
  }

  let(:with_address) { described_class.new(address_attributes) }
  let(:without_address) { described_class.new }

  describe '#full_address' do

    it 'builds a full address for maps' do
      with_address.full_address.should eql [with_address.street, with_address.city, with_address.state, with_address.zip].join(", ")
    end
    it 'builds a full address for maps' do
      with_address.address.should eql [with_address.street, with_address.zip].join(" ")
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
      with_address.map_link.should match /maps\.google\.com\/maps\?q=#{URI.escape(with_address.street)}/
    end
  end

end
