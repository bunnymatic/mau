require 'rails_helper'

describe Api::ArtistsController, elasticsearch: false do
  before do
    request.env['HTTP_REFERER'] = 'http://test.host/'
    create(:open_studios_event, :future)
  end

  describe '#register_for_open_studios' do
    context 'not logged in' do
      it 'returns unauthorized' do
        post :register_for_open_studios, params: { id: 'unknown' }
        expect(response).to be_unauthorized
      end
    end

    context 'logged in as a fan' do
      let(:fan) { create(:mau_fan) }
      before do
        login_as fan
      end

      it 'returns unauthorized' do
        post :register_for_open_studios, params: { id: 'unknown' }
        expect(response).to be_unauthorized
      end
    end

    context 'logged in as an artist' do
      before do
        login_as artist
      end
      context "who is can't do open studios" do
        let(:artist) { create(:artist, :active, :without_address) }

        it 'does not update your os status to true and returns an error' do
          get :register_for_open_studios, params: { id: artist.id, participation: '1' }
          expect(artist.reload).to_not be_doing_open_studios
          expect(response).to be_bad_request
          expect(JSON.parse(response.body)).to eq({
                                                    'success' => false,
                                                    'participant' => nil,
                                                  })
        end
      end

      context 'who can do open studios (in the mission)' do
        let(:artist) { create(:artist, :active, :in_the_mission) }

        it "updates your os status to true and redirects to your edit page if you're logged in" do
          get :register_for_open_studios, params: { id: artist.id, participation: '1' }
          expect(artist.reload).to be_doing_open_studios
          expect(response).to be_successful
          expect(JSON.parse(response.body)).to eq(
            'success' => true,
            'participant' => OpenStudiosParticipant.find_by(user: artist,
                                                            open_studios_event: OpenStudiosEvent.current).as_json(root: false),
          )
        end

        it "updates your os status to false and redirects to your edit page if you're logged in" do
          get :register_for_open_studios, params: { id: artist.id, participation: '0' }
          expect(artist.reload).not_to be_doing_open_studios
          expect(response).to be_successful
          expect(JSON.parse(response.body)).to eq(
            'success' => true,
            'participant' => nil,
          )
        end
      end
    end
  end
end
