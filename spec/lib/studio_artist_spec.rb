require 'spec_helper'

describe StudioArtist do

  let(:studios) { FactoryGirl.create_list :studio, 2 }
  let(:studio) { studios.first }
  let(:artist) { FactoryGirl.create(:artist, :active, studio: studio) }

  subject(:studio_artist) { StudioArtist.new(studio, artist) }

  context 'when the studio is not a studio' do
    it 'raises an error on construction' do
      expect{ StudioArtist.new('my studio', artist) }.to raise_error StudioArtistError
    end
  end

  context 'when the artist is not an artist' do
    it 'raises an error on construction' do
      expect{ StudioArtist.new(studio, 'da vinci') }.to raise_error StudioArtistError
    end
  end

  describe '#unaffiliate' do
    let(:unaffiliate) { subject.unaffiliate }
    before do
      unaffiliate
    end
    it 'returns true' do
      expect(unaffiliate).to be_true
    end

    it 'sets the artist\'s studio to indy' do
      expect(artist.studio_id).to eql 0
    end

    context 'artist is a manager' do
      it 'removes the manager role from the artist' do
        expect(artist.roles).to_not include Role.manager
      end
    end

    context 'artist is not in the studio' do

      let(:artist) { FactoryGirl.create(:artist, :active, studio: studios.first) }
      subject(:studio_artist) { StudioArtist.new(studios.last, artist) }

      it 'returns false' do
        expect(unaffiliate).to be_false
      end
      it 'does not change the artist affiliation' do
        unaffiliate
        expect(artist.studio).to_not eql Studio.indy
        expect(artist.studio).to eql studios.first
      end
    end

  end

end
