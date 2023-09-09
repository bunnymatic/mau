require 'rails_helper'

describe Api::V2::StudiosController do
  let(:studio) { create(:studio, :with_artists) }
  let(:headers) { {} }
  before do
    allow(FeatureFlags).to receive(:skip_api_authorization?).and_return(false)

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
        allow(StudioSerializer).to receive(:new).and_call_original
        make_request
      end
      context 'for an unknown studio' do
        let(:studio) { double(Studio, id: 1000, slug: 'whatever') }
        it 'returns a 400' do
          expect(response.status).to eql 400
        end
      end
      context 'for a known studio' do
        it_behaves_like 'successful api json'
        it 'uses the StudioSerializer' do
          expect(StudioSerializer).to have_received(:new)
        end
      end
      context 'for independent studio' do
        let(:studio) { IndependentStudio.new }
        it_behaves_like 'successful api json'
        it 'uses the StudioSerializer' do
          expect(StudioSerializer).to have_received(:new)
        end
      end
    end
  end
end
