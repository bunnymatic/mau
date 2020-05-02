# frozen_string_literal: true

shared_examples_for AddressMixin do
  let(:the_state) do
    Faker::Address.state
  end
  let(:base_attributes) do
    {
      street: Faker::Address.street_name,
      city: Faker::Address.city,
      zipcode: Faker::Address.zip_code,
    }
  end
  let(:with_state) do
    base_attributes.merge(state: the_state)
  end
  let(:with_addr_state) do
    base_attributes.merge(addr_state: the_state)
  end
  let(:with_address) do
    if described_class.new.respond_to? :addr_state
      described_class.new(with_addr_state.merge(lat: nil, lng: nil))
    else
      described_class.new(with_state)
    end
  end
  let(:without_address) { described_class.new }

  it 'builds a full address for maps' do
    expect(with_address.full_address).to eql [base_attributes[:street], base_attributes[:city],
                                              the_state, base_attributes[:zipcode].to_i].join(', ')
  end

  it 'provides a short address' do
    expect(with_address.address.to_s).to eql [base_attributes[:street], base_attributes[:zipcode].to_i].join(' ')
  end

  it 'address returns nil if there is no street' do
    expect(without_address.address.to_s).to be_blank
  end
  it 'full_address returns nil if there is no street' do
    expect(without_address.full_address).to be_blank
  end

  describe '#map_link' do
    it 'returns a google map link' do
      expect(with_address.map_link).to match(%r{maps\.google\.com/maps\?q=#{Regexp.quote(CGI.escape(base_attributes[:street]))}})
    end
  end

  describe '#compute_geocode' do
    it 'calls Geocode with the full address' do
      expect(Geokit::Geocoders::MultiGeocoder).to receive(:geocode)
        .with(with_address.full_address)
        .and_return(double('Geokit::GeoLoc', success: true,
                                             lat: 9.0,
                                             lng: 10.0))
      expect(with_address.send(:compute_geocode)).to eql [with_address.lat.to_f, with_address.lng.to_f]
    end
  end
end
