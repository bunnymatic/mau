# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::StudiosController do
  let(:studio) { create(:studio, :with_artists) }
  let(:headers) { {} }
  before do
    studio
  end

  describe '#show' do
    def make_request
      headers.each do |k, v|
        header k, v
      end
      get :show, params: { format: :json, id: studio.slug }
    end

    context 'without proper authorization' do
      it 'fails' do
        make_request
        expect(response.status).to eql 401
      end
    end

    context 'with proper authorization' do
      before do
        allow(controller).to receive(:require_authorization).and_return true
      end
      context 'for an unknown studio' do
        let(:studio) { double(Studio, id: 1000, slug: 'whatever') }
        it 'returns successful json' do
          make_request
          expect(response.status).to eql 400
        end
      end
      context 'for a known studio' do
        it 'returns successful json' do
          make_request
          expect(response).to be_success
          expect(response.content_type).to eq 'application/json'
        end
        it 'uses the StudioSerializer' do
          expect(StudioSerializer).to receive(:new).and_call_original
          make_request
        end
      end
      context 'for independent studio' do
        let(:studio) { IndependentStudio.new }
        it 'returns successful json' do
          make_request
          expect(response).to be_success
          expect(response.content_type).to eq 'application/json'
        end
        it 'uses the StudioSerializer' do
          expect(StudioSerializer).to receive(:new).and_call_original
          make_request
        end
      end
    end
  end
end
