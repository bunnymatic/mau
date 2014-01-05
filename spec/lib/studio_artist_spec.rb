require 'spec_helper'

describe StudioArtist do

  fixtures :users, :studios, :roles, :roles_users

  let(:artist) { users(:artist1) }
  let(:studio) { artist.studio }
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
      let(:studio) { (Studio.all - [artist.studio]).first }
      it 'returns false' do
        expect(unaffiliate).to be_true
      end
      it 'does not change the artist affiliation' do
        expect(artist.studio).to_not eql studio
        expect(artist.studio).to_not eql Studio.indy
      end
    end

  end

end
