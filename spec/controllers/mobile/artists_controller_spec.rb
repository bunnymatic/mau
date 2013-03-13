require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../../mobile_shared_spec')

describe ArtistsController do

  integrate_views

  fixtures :users, :roles_users
  fixtures :media, :art_pieces_tags, :art_piece_tags
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :studios

  before do
    # do mobile
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
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
        assert_select('li.mobile-menu', :minimum => Artist.active.select{|a| a.representative_piece}.count)
      end
    end

    context 'by first name' do
      before do
        get :by_firstname
      end
      it 'shows all active artists' do
        assert_select('li.mobile-menu', :minimum => Artist.active.select{|a| a.representative_piece}.count)
      end
    end
  end
  
  describe "#search" do
  end

  describe "#thumbs" do
    context 'with no params' do
      before do
        get :thumbs
      end
      it_should_behave_like "a regular mobile page"
      it_should_behave_like "non-welcome mobile page"
      
      it "shows 1 thumb per artist who has a representative image" do
        artists = Artist.active.select{ |a| a.representative_piece }
        assert_select 'div.thumb', :count => artists.count
      end
    end
    context 'with osonly=true' do
      before do
        get :thumbs, :osonly => 'true'
      end
      it_should_behave_like "a regular mobile page"
      it_should_behave_like "non-welcome mobile page"
      
      it "shows 1 thumb per artist who has a representative image and who is doing open studios" do
        
        artists = Artist.active.open_studios_participants.select{ |a| a.representative_piece }
        assert_select 'div.thumb', :count => artists.count
      end
    end
  end

  describe "#show" do
    before do
      @artist = users(:artist1)
      get :show, :id => @artist.id
    end
    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"

    it 'shows the user name' do
      assert_select 'div[data-role=content] div h2', :text => @artist.get_name
    end
    
    it 'shows the user\'s studio name' do
      assert_select('div[data-role=content] div.studio', :match => @artist.studio.name)
    end

    it 'shows the users address' do
      address = @artist.address_hash
      assert_select 'div', :text => address[:street]
      assert_select 'div', :text => address[:city]
    end
    it 'renders a bio' do
      assert_select '.bio_link.section'
      response.should_not have_tag '.bio_link a'
    end
    it 'renders a truncated bio if the bio is big' do
      a = Artist.find_by_login('ponceart')
      5.times.each do 
        a.artist_info.bio += a.artist_info.bio
      end
      a.artist_info.save
      get :show, :id => a.id
      assert_select('.bio_link.section', /\.\.\./)
      assert_select('.bio_link a', /Read More/)
    end

    it 'shows the bio content in the metatag' do
      assert_select('head').each do |tag|
        assert_select('meta[name=description]').each do |tag|
          tag.attributes['content'].should match /#{users(:artist1).bio[0..20]}/
        end
        assert_select('meta[property=og:description]').each do |tag|
          tag.attributes['content'].should match /#{users(:artist1).bio[0..20]}/
        end
      end
    end

    context 'invalid artist id' do
      before do
        get :show, :id => 'whatever yo'
      end
      it 'returns success' do
        response.should be_success
      end
      it 'reports that the user cannot be found' do
        assert_select '.error', /unable to find that artist/
      end
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
      before do
        get :bio, :id => users(:artist1).id
      end
      it "returns success" do
        response.should be_success
      end
      it 'renders the bio' do
        assert_select '.bio', /#{users(:artist1).bio}/
      end
      it 'shows the bio content in the metatag' do
        assert_select('head meta[name=description]').each do |tag|
          tag.attributes['content'].should match /#{users(:artist1).bio[0..20]}/
        end
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
