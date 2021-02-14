require 'rails_helper'

describe Admin::PalettesController do
  describe '#show' do
    before do
      login_as :admin
      get :show
    end
    it { expect(response).to be_successful }
  end
end
