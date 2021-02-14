require 'rails_helper'

describe SearchController, elasticsearch: false do
  describe '#index' do
    context 'finding by studio' do
      before do
        get :index, params: { q: 'stuff' }
      end
      it 'returns success' do
        expect(response).to be_successful
      end
    end
  end
end
