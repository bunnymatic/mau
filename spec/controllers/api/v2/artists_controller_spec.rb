# frozen_string_literal: true
require 'rails_helper'

describe Api::V2::ArtistsController do
  let(:studio) { create(:studio, :with_artists) }
  let(:headers) { {} }
  before do
    studio
    studio.artists.last.update_attributes(state: :susspended)
  end

  describe '#index' do
    def make_request
      get :index, params: { format: :json, studio: studio.slug }, headers: headers
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
      end
      it 'returns successful json' do
        make_request
        expect(response).to be_success
        expect(response.content_type).to eq 'application/json'
      end
      it 'returns only artists in the studio' do
        make_request
        artists = JSON.parse(response.body)['artists'].count
        expect(artists).to eql studio.artists.active.count
        expect(studio.artists.count).not_to eql studio.artists.active.count
      end
    end
  end
end
