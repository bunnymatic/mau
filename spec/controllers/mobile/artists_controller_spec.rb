require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../mobile_shared_spec')

describe ArtistsController do

  integrate_views

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :studios

  before do
    # do mobile
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)

    # stash an artist and art pieces
    apids =[]
    a = users(:artist1)
    @artist = a
  end

  describe "#index" do
    before do
      get :index
    end
    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"
    
    context 'invalid sortby param' do
      it 'responds with success page' do
        get :index, :sortby => 'crapass'
        response.should be_success
      end
    end

    context 'by last name' do
      before do
        get :by_lastname
      end
      it 'shows all active artists' do
        response.should have_tag('li.mobile-menu', :minimum => Artist.active.select{|a| a.representative_piece}.count)
      end
    end

    context 'by first name' do
      before do
        get :by_firstname
      end
      it 'shows all active artists' do
        response.should have_tag('li.mobile-menu', :minimum => Artist.active.select{|a| a.representative_piece}.count)
      end
    end
  end
  
  describe "#search" do
  end

  describe "#thumbs" do
    before do
      get :thumbs
    end
    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"

    it "shows 1 thumb per artist who has a representative image" do
      artists = Artist.active.select{ |a| a.representative_piece }
      response.should have_tag('div.thumb', :minimum => artists.count )
    end
  end

  describe "#show" do
    before do
      get :show, :id => @artist.id
    end
    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"

    it 'shows the user name' do
      response.should have_tag 'div[data-role=content] div h2', :text => @artist.get_name
    end
    
    it 'shows the user\'s studio name' do
      response.should have_tag('div[data-role=content] div.studio', :match => @artist.studio.name)
    end

    it 'shows the users address' do
      address = @artist.address_hash
      response.should have_tag 'div', :text => address[:street]
      response.should have_tag 'div', :text => address[:city]
    end

    context 'invalid artist id' do
      before do
        get :show, :id => 'whatever yo'
      end
      it 'returns success' do
        response.should be_succes
      end
      it 'reports that the user cannot be found'
    end

    context 'with user login as id' do
      it 'returns the user\'s page' do
        get :show, :id => 10
        response.should be_success
      end
    end

  end

  describe '#bio' do
    context 'for user with a bio' do
      integrate_views
      before do
        get :bio, :id => users(:artist1).id
      end
      it "returns success" do
        response.should be_success
      end
      it 'renders the bio' do
        response.should have_tag('.bio', users(:artist1).bio)
      end
    end
    context 'for user without a bio' do
      before do
        get :bio, :id => users(:wayout).id
      end
      it 'redirects to user\'s page' do
        response.should redirect_to artist_path(users(:wayout))
      end
    end
  end
end
