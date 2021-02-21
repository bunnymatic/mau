require 'rails_helper'

describe UpdateArtistService do
  let(:params) { {} }
  let(:artist) { create(:artist) }
  subject(:service) { described_class.new(artist, params) }

  include MockSearchService

  describe '.update' do
    before do
      stub_search_service!
    end

    describe 'without an artist' do
      it 'raises an error' do
        expect { described_class.new(nil, params) }.to raise_error UpdateArtistService::Error
      end
    end

    describe 'with a fan' do
      it 'raises an error' do
        expect { described_class.new(MauFan.new, params) }.to raise_error UpdateArtistService::Error
      end
    end

    describe 'with user attributes' do
      let(:params) do
        { firstname: 'BillyBob' }
      end
      it 'updates them' do
        service.update
        expect(artist.reload.firstname).to eql 'BillyBob'
      end

      it 'registers the change by adding a UserChangeEvent' do
        expect(UserChangedEvent).to receive(:create)
        service.update
      end
    end

    describe 'with artist info attributes' do
      let(:params) do
        { artist_info_attributes: { studionumber: '5' } }
      end
      it 'updates them' do
        service.update
        expect(artist.reload.studionumber).to eql '5'
      end
      it 'does not change the other artist info properties' do
        bio = artist.artist_info.bio
        info_id = artist.artist_info.id
        expect(bio).to be_present
        service.update
        expect(artist.reload.studionumber).to eql '5'
        expect(artist.artist_info.id).to eql info_id
      end
    end

    describe 'with a huge bio update' do
      let(:big_bio) { Faker::Lorem.paragraphs(number: 4).join }
      let(:params) do
        { artist_info_attributes: { bio: big_bio } }
      end
      it 'updates things without raising an error' do
        service.update
      end
    end

    describe 'when the login changes' do
      let(:params) do
        { login: 'newlogin' }
      end
      it 'updates the slug' do
        expect(artist.login).not_to eql 'newlogin'
        expect(artist.slug).not_to eql 'newlogin'
        service.update
        artist.reload
        expect(artist.slug).to eql 'newlogin'
        expect(artist.login).to eql 'newlogin'
      end
    end
  end

  describe '.update_os_status' do
    let!(:current_os) { create(:open_studios_event, start_date: 4.days.since) }
    subject(:update_os) { service.update_os_status }

    before do
      stub_mailer_email(ArtistMailer, :welcome_to_open_studios)
    end
    context 'when the artist cannot do open studios (no address)' do
      let(:artist) { create(:artist, :without_address) }

      subject(:update_os) { service.update_os_status }
      it 'returns false' do
        expect(update_os).to eq false
      end
      it 'does not email the artist' do
        update_os
        expect(ArtistMailer).to_not have_received :welcome_to_open_studios
      end

      it 'does not save an open studios sign up event' do
        expect { update_os }.to change(OpenStudiosSignupEvent, :count).by(0)
      end
    end

    context 'when the artist is already doing open studios' do
      let(:artist) { create(:artist, doing_open_studios: current_os) }

      context 'and they update the status to "doing" it' do
        let(:params) { { os_participation: '1' } }
        it 'does not change the open studios flag' do
          update_os
          # this find forces the artist_info reload
          expect(Artist.find(artist.id)).to be_doing_open_studios
        end
        it 'does not email the artist' do
          update_os
          expect(ArtistMailer).to_not have_received :welcome_to_open_studios
        end

        it 'does not save an open studios sign up event' do
          expect { update_os }.to change(OpenStudiosSignupEvent, :count).by(0)
        end
      end

      context 'and they update the status to "not doing" it' do
        let(:params) { { os_participation: '0' } }
        it 'sets the open studios flag' do
          update_os
          # this find forces the artist_info reload
          expect(Artist.find(artist.id)).to_not be_doing_open_studios
        end
        it 'does not email the artist' do
          update_os
          expect(ArtistMailer).to_not have_received :welcome_to_open_studios
        end
        it 'saves the open studios sign up event' do
          expect { update_os }.to change(OpenStudiosSignupEvent, :count).by(1)
        end
      end
    end
    context 'when the artist not yet registered for open studios' do
      context 'and they update the status to "doing" it' do
        let(:params) { { os_participation: '1' } }
        it 'sets the open studios flag' do
          update_os
          # this find forces the artist_info reload
          expect(Artist.find(artist.id)).to be_doing_open_studios
        end
        it 'emails the artist' do
          update_os
          expect(ArtistMailer).to have_received(:welcome_to_open_studios).with(artist, current_os)
        end
        it 'saves an open studios sign up event' do
          expect { update_os }.to change(OpenStudiosSignupEvent, :count).by(1)
        end
        it 'returns the new OpenStudiosParticipant record' do
          participant = update_os
          # this find forces the artist_info reload
          expect(participant).to eq OpenStudiosParticipant.where(user: artist, open_studios_event: current_os).take
        end
      end

      context 'and they update the status to "not doing" it' do
        let(:params) { { os_participation: '0' } }
        it 'does not change the open studios flag' do
          update_os
          # this find forces the artist_info reload
          expect(Artist.find(artist.id)).to_not be_doing_open_studios
        end

        it 'does not email the artist' do
          update_os
          expect(ArtistMailer).to_not have_received :welcome_to_open_studios
        end

        it 'does not save the open studios sign up event' do
          expect { update_os }.to change(OpenStudiosSignupEvent, :count).by(0)
        end

        it 'returns nil' do
          expect(update_os).to be_nil
        end
      end
    end
  end
end
