require 'rails_helper'

describe Api::V2::ArtPiecesController do
  describe '#index' do
    render_views

    context 'when there is art for an artist' do
      let(:artist) { create(:artist, :active) }
      let(:art_pieces) { create_list(:art_piece, 3, artist:) }

      before do
        allow(controller).to receive(:require_authorization).and_return true
        art_pieces
      end

      it 'returns art pieces' do
        get :index, params: { artist_id: artist.id, format: :json }

        expect(response).to be_successful
        json = JSON.parse(response.body)['data']
        expect(json).to have(3).art_pieces
      end

      context 'with count parameter' do
        it 'returns no more than count pieces' do
          get :index, params: { count: 2, artist_id: artist.id, format: :json }

          expect(response).to be_successful
          json = JSON.parse(response.body)['data']
          expect(json).to have(2).art_pieces
        end

        it 'returns all pieces if count is bigger than all' do
          get :index, params: { count: 20, artist_id: artist.id, format: :json }

          expect(response).to be_successful
          json = JSON.parse(response.body)['data']
          expect(json).to have(3).art_pieces
        end
      end
    end

    context 'for unknown artist' do
      it 'returns nothing' do
        get :index, params: { artist_id: 123, format: :json }
        expect(response).to be_successful
        expect(response.body).to eq '{}'
      end

      it 'includes no robot headers' do
        get :index, params: { artist_id: 123, format: :json }
        expect(response.headers['X-Robots-Tag']).to eq('noindex')
      end
    end
  end
end
