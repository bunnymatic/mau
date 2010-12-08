require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe ArtistsController do

  integrate_views

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces

  describe "Update Artist" do
    before(:each) do
      @a = users(:artist1)
      @a.save!
      @b = artist_infos(:artist1)
      @b.artist_id = @a.id
      @b.save!
    end
    context "while not logged in" do
      it_should_behave_like "get/post update redirects to login"
    end
    context "while logged in" do
      before(:each) do
        @new_bio = "this is the new bio"
        @old_bio = @a.artist_info.bio
        login_as(@a)
        @logged_in_user = @a
      end
      context "submit" do
        before do
          post :update, { :commit => 'submit', :artist => { :artist_info => {:bio => @newbio }}}
        end
        context "post with new bio data" do
          it "redirects to to edit page" do
            flash[:notice].should eql 'Update successful'
            response.should redirect_to(edit_artist_path(@a))
          end
          it "shows new bio in edit form" do
            get :edit
            response.should have_tag('textarea#artist_artist_info_bio')
          end
        end
      end
      context "cancel post with new bio data" do
        before do
          post :update, { :commit => 'cancel', :artist => { :artist_info => {:bio => @newbio }}}
        end
        it "redirects to user page" do
          response.should redirect_to(user_path(@a))
        end
        it "should have no flash notice" do
          flash[:notice].should be_nil
        end
        it "shouldn't change anything" do
          get :show, :id => @a.id
          response.should have_tag("div.bio-container")
          response.should include_text(@old_bio)
        end
      end
    end
      
      
  end

  describe "#edit" do
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
      it_should_behave_like "redirects to login"
    end
    context "while logged in" do
      before(:each) do
        login_as(@a)
        @logged_in_user = @a
      end
      context "GET" do
        before do
          get :edit
        end
        it_should_behave_like "logged in user"

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
          response.should have_tag("input#artist_url[value=#{@a.url}]")
        end
        it "has the artists correct links in their respective fields" do
          [:facebook, :blog].each do |k| 
            linkval = @a.send(k)
            linkid = "artist_artist_info_#{k}"
            tag = "input##{linkid}[value=#{linkval}]"
            response.should have_tag(tag)
          end
        end
        it "has the artists' bio textarea field" do
          get :edit
          response.should have_tag("textarea#artist_artist_info_bio", @a.artist_info.bio)
        end
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

    context "while not logged in" do
      context "looking at an artist page" do
        before(:each) do 
          get :show, :id => @a.id
        end
        it "returns a page" do
          response.should be_success
        end
        it "has a twitter share icon it" do
          response.should have_tag '.micro-icon.twitter'
        end
        it "has a facebook share icon on it" do
          response.should have_tag('.micro-icon.facebook')
        end
        it "has a 'favorite' icon on it" do
          response.should have_tag('.micro-icon.heart')
        end
        it 'has thumbnails' do
          response.should have_tag("#bigthumbcolumn")
        end
        it 'has other thumbnails' do
          response.should have_tag('.artist-pieces')
        end
      end
    end

    context "while logged in" do
      before do
        login_as(@a)
        @logged_in_user = @a
      end
      context "looking at your own page" do
        before(:each) do 
          get :show, :id => @a.id
        end
        it_should_behave_like "logged in user"
        it "website is present" do
          response.should have_tag("div#u_website a[href=#{@a.url}]")
        end
        it "facebook is present and correct" do
          response.should have_tag("div#u_facebook a[href=#{@a.artist_info.facebook}]")
        end
        it "should not have heart icon" do
          response.should_not have_tag(".micro-icon.heart")
        end
        it "should not have note icon" do
          response.should_not have_tag(".micro-icon.email")
        end
      end
      context "looking for an artist that is not active" do
        it "reports cannot find artist" do
          get :show, :id => users(:aaron).id
          response.should have_tag('.rcol .error-msg')
          response.body.should match(/artist you were looking for was not found/)
        end
      end
      context "looking at someone elses page" do
        before(:each) do 
          a = users(:joeblogs)
          b = artist_infos(:joeblogs)
          b.artist_id = a.id
          b.save
          get :show, :id => a.id
        end
        it_should_behave_like "logged in user"
        it "should have heart icon" do
          response.should have_tag(".micro-icon.heart")
        end
        it "should have note icon" do
          response.should have_tag(".micro-icon.email")
        end
      end
      context "after a user favorites the logged in artist and show the artists page" do
        before do
          @u = users(:quentin)
          @u.add_favorite(@a)
          login_as(@a)
          get :show, :id => @a.id
        end
        it "returns success" do
          response.should be_success
        end
        it "has the user in the 'who favorites me' section" do
          response.should have_tag('#favorites_me div.thumb')
        end
        it "has a link to that users page" do
          response.should have_tag("#favorites_me a[href^=/users/#{@u.id}]")
        end
      end
    end

    context "while not logged in" do
      before(:each) do 
        get :show, :id => @a.id
      end
      it_should_behave_like "not logged in"
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
    context "post to set arrangement" do
      before do
        post :setarrangement, { :neworder => "1,2" }
      end
      it_should_behave_like "redirects to login"
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
