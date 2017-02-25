# frozen_string_literal: true
require 'rails_helper'

describe ArtistProfileImage do
  let(:artist) { FactoryGirl.create(:artist, :active, :with_studio) }

  describe '#get_path' do
    let(:directory) { 'artistdata' }
    let(:size) { :thumb }
    let(:prefix) { 't_' }
    let(:expected_path) do
      ('/'+ [directory,artist.id,'profile', prefix+artist.profile_image].join('/'))
    end
    context 'thumb' do
      it 'returns the right path' do
        expect(ArtistProfileImage.get_path(artist, size)).to eql expected_path
      end
    end
    context 'small' do
      let(:size) { :small }
      let(:prefix) { 's_' }
      it 'returns the right path' do
        expect(ArtistProfileImage.get_path(artist, size)).to eql expected_path
      end
    end
    context 'medium' do
      let(:size) { :medium }
      let(:prefix) { 'm_' }
      it 'returns the right path' do
        expect(ArtistProfileImage.get_path(artist, size)).to eql expected_path
      end
    end
    context 'large' do
      let(:size) { :large }
      let(:prefix) { 'l_' }
      it 'returns the right path' do
        expect(ArtistProfileImage.get_path(artist, size)).to eql expected_path
      end
    end
    context 'original' do
      let(:size) { :original }
      let(:prefix) { '' }
      it 'returns the right path' do
        expect(ArtistProfileImage.get_path(artist, size)).to eql expected_path
      end
    end
  end
end
