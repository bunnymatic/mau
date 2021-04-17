require 'rails_helper'

describe OpenStudiosSubdomain::MainController do
  before do
    create(:open_studios_event)
  end
  describe '#get' do
    it 'loads the gallery and presenter for the index page' do
      get :index
      expect(assigns(:gallery)).to be_a_kind_of(OpenStudiosCatalogArtists)
      expect(assigns(:presenter)).to be_a_kind_of(OpenStudiosCatalogPresenter)
    end
  end
end
