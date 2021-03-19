require 'rails_helper'

describe OpenStudiosSubdomain::MainController do
  before do
    create(:open_studios_event)
  end
  describe '#get' do
    describe 'not xhr' do
      it 'loads the gallery and presenter for the index page' do
        get :index
        expect(assigns(:gallery)).to be_a_kind_of(ArtistsGallery)
        expect(assigns(:presenter)).to be_a_kind_of(OpenStudiosCatalogPresenter)
      end
    end
    describe 'xhr' do
      it 'loads the gallery with the next page' do
        get :index, xhr: true, params: { p: 4 }
        gallery = assigns(:gallery)
        expect(gallery).to be_a_kind_of(ArtistsGallery)
        expect(gallery.current_page).to eq 4
        expect(assigns(:presenter)).to be_nil
      end
    end
  end
end
