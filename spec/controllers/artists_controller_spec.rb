require 'spec_helper'

include AuthenticatedTestHelper

describe ArtistsController do

  fixtures :users
  fixtures :art_pieces

  describe "- arrange art" do
    def save_artist_with_artpieces
      apids =[]
      a = users(:artist1)
      a.save!
      ap = art_pieces(:artpiece1)
      ap.user_id = a.id
      ap.save!
      apids << ap.id
      ap = art_pieces(:artpiece2)
      ap.user_id = a.id
      ap.save!
      apids << ap.id
      ap = art_pieces(:artpiece3)
      ap.user_id = a.id
      ap.save!
      apids << ap.id
      { :artist => a, :art_piece_ids => apids }
    end

    it 'should put representative as last uploaded piece' do
      r = save_artist_with_artpieces
      a = r[:artist]
      a = Artist.find_by_id(a.id)
      a.representative_piece.title.should == 'third'
    end

    it 'should return art_pieces in created time order' do
      r = save_artist_with_artpieces
      a = r[:artist]
      aps = a.art_pieces
      aps.count.should == 3
      aps[0].title.should == 'third'
      aps[1].title.should == 'second'
      aps[2].title.should == 'first'
    end

    it 'should return art_pieces in new order (2,1,3)' do
      r = save_artist_with_artpieces
      a = r[:artist]
      apids = r[:art_piece_ids]
      order1 = [ apids[1], apids[0], apids[2] ]
      
      login_as(a)

      # user should be logged in now
      post :setarrangement, { :neworder => order1.join(",") }
      response.code.should == "302"

      aid = a.id
      a = Artist.find(aid)
      aps = a.art_pieces
      aps.count.should == 3
      aps[0].title.should == 'second'
      aps[1].title.should == 'first'
      aps[2].title.should == 'third'
      aps[0].artist.representative_piece.id.should==aps[0].id

    end

    it 'should return art_pieces in new order (1,3,2)' do
      r = save_artist_with_artpieces
      a = r[:artist]
      apids = r[:art_piece_ids]
      order1 = [ apids[0], apids[2], apids[1] ]
      login_as(a)

      post :setarrangement, { :neworder => order1.join(",") }
      response.code.should == "302"

      aid = a.id
      a = Artist.find(aid)
      aps = a.art_pieces
      aps.count.should == 3
      aps[0].title.should == 'first'
      aps[1].title.should == 'third'
      aps[2].title.should == 'second'
      aps[0].artist.representative_piece.id.should==aps[0].id
    end
  end
  describe '- logged out' do
    it 'should not allow connection to edit endpoints' do
      post :setarrangement, { :neworder => "1,2" }
        response.code.should == '302'
      response.location.should == new_session_url
    end
  end
  describe "- route generation" do
    it "should map controller artists, id 10 and action show to /artists/10" do
      route_for(:controller => "artists", :id => '10', :action => 'show').should == '/artists/10'
    end
    it "should map edit action properly" do
      route_for(:controller => "artists", :id => '10', :action => "edit").should == '/artists/10/edit'
    end
    
    it "should map users/index to artists" do
      route_for(:controller => "artists", :action => "index").should == '/artists'
    end
  end
  describe "- named routes" do
    it "should have destroyart as artists collection path" do
      destroyart_artists_path.should == '/artists/destroyart'
    end      
    it "should have arrangeart as artists collection path" do
      arrangeart_artists_path.should == '/artists/arrangeart'
    end      
    it "should have setarrangement as artists collection path" do
      setarrangement_artists_path.should == '/artists/setarrangement'
    end      
    it "should have deleteart as artists collection path" do
      deleteart_artists_path.should == '/artists/deleteart'
    end      
  end
  describe "- route recognition" do
    it "should recognize PUT /artists/10 as update" do
      params_from(:put, "/artists/10").should == {:controller => 'artists', :action => 'update', :id => '10' }
    end
    it "should recognize GET /artists/10 as show" do
      params_from(:get, "/artists/10").should == {:controller => 'artists', :action => 'show', :id => '10' }
    end
    it "should recognize POST /artists/10 as nonsense (action 10)" do
      params_from(:post, "/artists/10").should == {:controller => 'artists', :action => '10' }
    end
    it "should recognize DELETE /artists/10 as show" do
      params_from(:delete, "/artists/10").should == {:controller => 'artists', :action => 'destroy', :id => '10' }
    end
  end
end
