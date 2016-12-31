require 'rails_helper'

describe CacheKeyService do
  let(:service) { described_class }
  let(:artist) { instance_double(Artist, id: 20) }
  it 'returns a key for representative_art' do
    expect(service.representative_art(artist)).to eql 'representative_art20'
  end
end
