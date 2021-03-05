require 'rails_helper'

describe Api::OpenStudiosParticipantsController do
  describe 'update' do
    let!(:os_event) { create(:open_studios_event) }
    let(:artist) { create(:artist, doing_open_studios: true) }
    let(:participant) do
      artist.open_studios_participants.first
    end
    let(:new_attrs) do
      FactoryBot.attributes_for(:open_studios_participant, user: artist, open_studios_event: os_event).except(:user_id, :id)
    end
    before do
      request.env['HTTP_REFERER'] = 'http://test.host/'
    end

    context 'when not logged in' do
      before do
        os_event
      end

      it 'refuses service' do
        put :update, params: { artist_id: artist, id: participant.id, open_studios_participant: new_attrs }
        expect(response).to be_unauthorized
      end
    end

    context 'when logged as the wrong artist' do
      let(:other_artist) { create(:artist) }

      before do
        logout
        login_as(other_artist)
      end
      it 'refuses service' do
        put :update, params: { artist_id: artist, id: participant.id, open_studios_participant: new_attrs }
        expect(response).to be_unauthorized
      end
    end

    context 'when logged in as the artist' do
      before do
        login_as artist
      end

      it 'updates the entry with good data' do
        participant = artist.open_studios_participants.first
        put :update, params: { artist_id: artist.id, id: participant.id, open_studios_participant: new_attrs }
        participant.reload

        expect(response).to be_ok
        expect(participant.shop_url).to eq(new_attrs[:shop_url])
        expect(participant.youtube_url).to eq(new_attrs[:youtube_url])
        expect(participant.video_conference_url).to eq(new_attrs[:video_conference_url])
        expect(participant.show_email).to eq(new_attrs[:show_email])
        expect(participant.show_phone_number).to eq(new_attrs[:show_phone_number])
      end

      it 'properly updates video_conference_schedule' do
        participant = artist.open_studios_participants.first
        put :update, params: {
          artist_id: artist.id,
          id: participant.id,
          open_studios_participant: {
            video_conference_schedule: { one: 2 },
          },
        }
        participant.reload

        expect(response).to be_ok
        expect(participant.video_conference_schedule).to eq({ 'one' => '2' })
      end

      it 'returns json errors if data is bad' do
        bad_attrs = new_attrs.merge(shop_url: 'httwhatever')
        participant = artist.open_studios_participants.first
        put :update, params: { artist_id: artist.id, id: participant.id, open_studios_participant: bad_attrs }

        expect(response).to be_bad_request
        errors = JSON.parse(response.body)['errors']
        expect(errors).to have_key('shop_url')
      end
    end
  end
end
