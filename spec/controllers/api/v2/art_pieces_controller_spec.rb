# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::ArtPiecesController do
  describe '#index' do
    render_views

    before do
      allow(controller).to receive(:require_authorization).and_return true
    end

    it 'returns nothing for an unknown artist' do
      get :index, params: { artist_id: 123, format: :json }
      expect(response).to be_success
      expect(response.body).to eq '{}'
    end
  end
end
