require 'rails_helper'

describe Admin::PalettesController do
  describe '#show' do
    before do
      login_as :admin
      allow_any_instance_of(ScssFileReader).to receive(:parse_colors).and_return([['black', '000'], ['white', 'ffffff']])
      get :show
    end
    it{ expect(response).to be_success }
  end
end
