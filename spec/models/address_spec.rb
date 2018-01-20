# frozen_string_literal: true

require 'rails_helper'

describe Address do
  let(:artist) { create :artist }
  let(:studio) { create :studio }
  let(:model) { Artist.new }
  subject(:address) { described_class.new(model) }

  describe 'for an artist' do
    context 'with an address' do
      let(:model) { artist }

      its(:geocoded?) { is_expected.to eq true }
      its(:street) { is_expected.to eq artist.street }
      its(:city) { is_expected.to eq artist.city }
      its(:state) { is_expected.to eq artist.addr_state }
      its(:lat) { is_expected.to eq artist.lat }
      its(:lng) { is_expected.to eq artist.lng }
      its(:to_s) { is_expected.to eq([artist.street, '94110'].join(' ')) }
      its(:present?) { is_expected.to eq true }
      its(:empty?) { is_expected.to eq false }

      context 'who is in a studio' do
        let(:model) { create :artist, studio: studio }

        it 'returns the address information of the studio' do
          expect(address).to eq studio.address
        end
      end
    end
    context 'without an address' do
      let(:model) { create :artist, :without_address }

      its(:geocoded?) { is_expected.to eq false }
      its(:street) { is_expected.to be_blank }
      its(:present?) { is_expected.to eq false }
      its(:empty?) { is_expected.to eq true }
      its(:to_s) { is_expected.to be_empty }
    end
  end

  describe 'for a studio' do
    let(:model) { studio }
    its(:geocoded?) { is_expected.to eq true }
    its(:street) { is_expected.to eq studio.street }
    its(:city) { is_expected.to eq studio.city }
    its(:state) { is_expected.to eq studio.state }
    its(:lat) { is_expected.to eq studio.lat }
    its(:lng) { is_expected.to eq studio.lng }
    its(:to_s) { is_expected.to eq([studio.street, studio.zip].join(' ')) }
    its(:present?) { is_expected.to eq true }
    its(:empty?) { is_expected.to eq false }
  end

  describe "for an model that doesn't have lat, lng or street attribute" do
    it 'raises an ArgumentError on initialization' do
      expect { Address.new(ArtPiece.new) }.to raise_error(ArgumentError)
    end
  end
end
