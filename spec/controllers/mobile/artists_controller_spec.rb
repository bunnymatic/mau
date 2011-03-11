thisdir = File.expand_path(File.dirname(__FILE__)) + "/"

require thisdir + '../../spec_helper'
require thisdir + 'mobile_shared_spec.rb'


describe Mobile::ArtistsController do

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :studios

  before do
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

  integrate_views
  describe "index" do
    before do
      get :index
    end
    it_should_behave_like "a regular mobile page"
    
    it "includes link for artists by first name" do
      response.should have_tag("li.mobile-menu a[href=/artists/?sortby=firstname]", :match => /artists by first name/i)
    end
    it "includes link for artists by last name" do
      response.should have_tag("li.mobile-menu a[href=/artists/?sortby=lastname]", :match => /artists by last name/i)
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
        get :index, :sortby => 'lastname'
      end
      it 'shows all active artists' do
        response.should have_tag('li.mobile-menu', :minimum => Artist.active.count)
      end
    end

    context 'by first name' do
      before do
        get :index, :sortby => 'firstname'
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

    it 'shows the user name' do
      response.should have_tag '.info h4', :text => @artist.get_name
    end
  
    it 'shows the user\'s studio name' do
      response.should have_tag('div.info .studio', :match => @artist.studio.name)
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

