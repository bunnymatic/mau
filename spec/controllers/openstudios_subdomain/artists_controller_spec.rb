require 'rails_helper'

describe OpenStudiosSubdomain::ArtistsController do
  let(:artist) { create(:artist) }
  let(:active_artist_doing_open_studios) do
    current_os
    create(:artist, :active, doing_open_studios: true)
  end
  let(:current_os) { create(:open_studios_event) }

  describe '#show' do
    context 'with virtual_open_studios flag on' do
      before do
        mock_app_config(:features, { virtual_open_studios: true })
      end

      it 'renders successfully if the artist is active and doing open studios' do
        get :show, params: { id: active_artist_doing_open_studios }
        expect(response).to be_ok
      end

      it 'redirects to open_studios_path if the artist is not doing open studios' do
        get :show, params: { id: artist }
        expect(response).to redirect_to(open_studios_path)
        expect(flash[:error]).to eq "It doesn't look like that artist is doing open studios"
      end

      it 'redirects to open_studios_path if the artist is unknown' do
        get :show, params: { id: 'nobody-we-know' }
        expect(response).to redirect_to(open_studios_path)
        expect(flash[:error]).to eq "It doesn't look like that artist is doing open studios"
      end

      it 'redirects to open_studios_path if the artist is not active' do
        artist.update(state: :pending)
        get :show, params: { id: artist }
        expect(response).to redirect_to(open_studios_path)
        expect(flash[:error]).to eq "It doesn't look like that artist is doing open studios"
      end
    end

    context 'with virtual open studios flag off' do
      before do
        mock_app_config(:features, { virtual_open_studios: false })
      end
      it 'renders error page' do
        get :show, params: { id: active_artist_doing_open_studios }
        expect(response).to redirect_to('/error')
      end
    end
  end
end
