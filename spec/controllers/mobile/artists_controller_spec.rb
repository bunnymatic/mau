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
    a.studio = Studio.all[1]
    a.save!
    ap = art_pieces(:artpiece1)
    ap.artist_id = a.id
    ap.save!
    apids << ap.id
    ap = art_pieces(:artpiece2)
    ap.artist_id = a.id
    ap.save!
    apids << ap.id
    ap = art_pieces(:artpiece3)
    ap.artist_id = a.id
    ap.save!
    apids << ap.id
    info = artist_infos(:artist1)
    info.artist_id = a.id
    info.save!
    a.artist_info = info
    @artist = a
    @artpieces = apids
  end

  describe "index" do
    before do
      get :index
    end
    it_should_behave_like "a regular mobile page"
    
    it "includes link for artists by first name" do
      response.should have_tag("li.mobile-menu a[href=/artists_by_firstname]", :match => /artists by first name/i)
    end
    it "includes link for artists by last name" do
      response.should have_tag("li.mobile-menu a[href=/artists_by_lastname]", :match => /artists by last name/i)
    end
    it "includes link to search for artist by name" do
      response.should have_tag("li.mobile-menu a[href=/artists/search]", :match => /earch/)
    end
    
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
        response.should have_tag('li.mobile-menu', :minimum => Artist.active.count)
      end
    end

    context 'by first name' do
      before do
        get :by_firstname
      end
      it 'shows all active artists' do
        response.should have_tag('li.mobile-menu', :minimum => Artist.active.count)
      end
    end
  end
  
  describe "search" do
  end

  describe "#show" do
    before do
      get :show, :id => @artist.id
    end
    it_should_behave_like "a regular mobile page"

    it 'shows the user\'s representative image' do
      response.should have_tag("img[src=#{@artist.representative_piece.get_path}]")
    end
    
    it 'shows the user name' do
      response.should have_tag '.m-content h2', :text => @artist.get_name
    end
    
    it 'shows the user\'s studio name' do
      response.should have_tag('.m-content .studio', :match => @artist.studio.name)
    end

    it 'shows the users address' do
      address = @artist.address_hash
      response.should have_tag 'div', :text => address[:street]
      response.should have_tag 'div', :text => address[:city]
    end

    context 'invalid artist id' do
      it 'returns success'
      it 'reports that the user cannot be found'
    end

    context 'with user login as id' do
      it 'returns the user\'s page' do
        get :show, :id => 10
        response.should be_success
      end
    end

  end
end
