require "spec_helper"

include AuthenticatedTestHelper

describe ArtistsController do

  integrate_views

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces

  describe "GET edit" do
    before(:each) do
      @a = users(:artist1)
      @a.save!
      @b = artist_infos(:artist1)
      @b.artist_id = @a.id
      @b.save!
    end
    context "while not logged in" do
      before(:each) do 
        get :edit
      end
      it "redirects to login" do
        response.should redirect_to(new_session_path)
      end
    end
    context "while logged in" do
      before(:each) do
        login_as(@a)
        get :edit
      end
      it "GET returns 200" do
        response.should be_success
      end
      it "has the edit form" do
        response.should have_tag("div#artist_edit");
      end
      it "has the artists email in the email form input field" do
        response.should have_tag("#info .inner-sxn input#artist_email[value=#{@a.email}]")
      end
      it "has the website input box with the artists website in it" do
        response.should have_tag("input#artist_url[value=#{@a.url}]");
      end
      it "has the artists correct links in their respective fields" do
        [:facebook].each() do |key| 
          linkval = @a.send(key)
          linkid = "artist_artist_info_#{key}"
          tag = "input##{linkid}[value=#{linkval}]"
          response.should have_tag(tag)
        end
      end
      it "has the artists' bio textarea field" do
        response.should have_tag("textarea#artist_artist_info_bio", @a.artist_info.bio)
      end
    end
  end
  
  describe "profile page" do
    before(:each) do 
      @a = users(:artist1)
      @b = artist_infos(:artist1)
      @a.save
      @b.artist_id = @a.id
      @b.save
    end

    context "while logged in" do
      before(:each) do 
        login_as(@a)
        get :show, :id => @a.id
      end
      it "header bar should say hello" do
        response.should have_tag("span.logout-nav")
      end
      it "header bar should have my login name as a link" do
        response.should have_tag("span.logout-nav a", :text => @a.login)
      end
      it "header bar should have logout tag" do
        response.should have_tag("span.last a[href=/logout]");
      end
      it "website is present" do
        response.should have_tag("div#u_website a[href=#{@a.url}]")
      end
      it "facebook is present and correct" do
        response.should have_tag("div#u_facebook a[href=#{@a.artist_info.facebook}]")
      end
    end

    context "while not logged in" do
      before(:each) do 
        get :show, :id => @a.id
      end
      it "header bar should have login link" do
        response.should have_tag("#login_toplink a", :text => "log in")
      end
      it "website is present" do
        response.should have_tag("div#u_website a[href=#{@a.url}]")
      end
      it "facebook is present and correct" do
        response.should have_tag("div#u_facebook a[href=#{@a.artist_info.facebook}]")
      end
    end
  end

  describe "arrange art for an artist " do
    before(:each) do 
      # stash an artist and art pieces
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
      info = artist_infos(:artist1)
      info.artist_id = a.id
      info.save!
      a.artist_info = info
      @artist = a
      @artpieces = apids
    end
    it "most recently uploaded piece is the representative" do
      a = Artist.find_by_id(@artist.id)
      a.artist_info.representative_piece.title.should == "third"
    end

    it "returns art_pieces in created time order" do
      aps = @artist.art_pieces
      aps.count.should == 3
      aps[0].title.should == "third"
      aps[1].title.should == "second"
      aps[2].title.should == "first"
    end
    context "while logged" do
      before(:each) do
        login_as(@artist)
      end
      it "returns art_pieces in new order (2,1,3)" do
        order1 = [ @artpieces[1], @artpieces[0], @artpieces[2] ]

        # user should be logged in now
        post :setarrangement, { :neworder => order1.join(",") }
        response.should redirect_to user_url(@artist)
        a = Artist.find(@artist.id)
        aps = a.art_pieces
        aps.count.should == 3
        aps[0].title.should == "second"
        aps[1].title.should == "first"
        aps[2].title.should == "third"
        aps[0].artist.artist_info.representative_piece.id.should==aps[0].id
        
      end

      it "returns art_pieces in new order (1,3,2)" do
        order1 = [ @artpieces[0], @artpieces[2], @artpieces[1] ]
        
        post :setarrangement, { :neworder => order1.join(",") }
        response.should redirect_to user_url(@artist)
        
        a = Artist.find(@artist.id)
        aps = a.art_pieces
        aps.count.should == 3
        aps[0].title.should == "first"
        aps[1].title.should == "third"
        aps[2].title.should == "second"
        aps[0].artist.artist_info.representative_piece.id.should==aps[0].id
      end
    end
  end
  describe "- logged out" do
    it "redirects from setarrangement endpoint to login" do
      post :setarrangement, { :neworder => "1,2" }
        response.code.should == "302"
      response.location.should == new_session_url
    end
  end
  describe "- route generation" do
    it "should map controller artists, id 10 and action show to /artists/10" do
      route_for(:controller => "artists", :id => "10", :action => "show").should == "/artists/10"
    end
    it "should map edit action properly" do
      route_for(:controller => "artists", :id => "10", :action => "edit").should == "/artists/10/edit"
    end
    
    it "should map users/index to artists" do
      route_for(:controller => "artists", :action => "index").should == "/artists"
    end
  end
  describe "- named routes" do
    it "should have destroyart as artists collection path" do
      destroyart_artists_path.should == "/artists/destroyart"
    end      
    it "should have arrangeart as artists collection path" do
      arrangeart_artists_path.should == "/artists/arrangeart"
    end      
    it "should have setarrangement as artists collection path" do
      setarrangement_artists_path.should == "/artists/setarrangement"
    end      
    it "should have deleteart as artists collection path" do
      deleteart_artists_path.should == "/artists/deleteart"
    end      
  end
  describe "- route recognition" do
    context "/artists/10/edit" do
      it "map get to artists controller edit method" do
        params_from(:get, "/artists/10/edit").should == {:controller => "artists", :action => "edit", :id => "10" }
      end
    end
    context "/artists/10" do
      it "map PUT to update" do 
        params_from(:put, "/artists/10").should == {:controller => "artists", :action => "update", :id => "10" }
      end
      it "map GET to show" do
        params_from(:get, "/artists/10").should == {:controller => "artists", :action => "show", :id => "10" }
      end
      it "map POST to action == 10 (nonsense)" do
        params_from(:post, "/artists/10").should == {:controller => "artists", :action => "10" }
      end
      it "map DELETE /artists/10 as destroy" do
        params_from(:delete, "/artists/10").should == {:controller => "artists", :action => "destroy", :id => "10" }
      end
    end
  end
end
