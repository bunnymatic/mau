require 'rails_helper'

describe Api::V2::ArtistsController do
  let(:studio) { create(:studio, :with_artists) }
  let(:headers) { {} }
  before do
    studio
    studio.artists.last.update(state: :susspended)
  end

  describe '#index' do
    def make_request
      headers.each { |k, v| header k, v }
      get :index, params: { format: :json, studio: studio.slug }
    end

    context 'without proper authorization' do
      it 'fails' do
        make_request
        expect(response.status).to eql 401
      end
    end

    context 'with proper authorization' do
      render_views
      before do
        allow(controller).to receive(:require_authorization).and_return true
        make_request
      end
      it_behaves_like 'successful api json'
      it 'returns only artists in the studio' do
        artists = JSON.parse(response.body)['data'].count
        expect(artists).to eql studio.artists.active.count
        expect(studio.artists.count).not_to eql studio.artists.active.count
      end
    end
  end
end
