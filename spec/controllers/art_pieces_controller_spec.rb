require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../controllers_helper')
include AuthenticatedTestHelper

describe ArtPiecesController do

  integrate_views

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :media

  before(:each) do 
    # stash an artist and art pieces
    art_pieces =[]
    m1 = media(:medium1)
    m1.save!
    m2 = media(:medium2)
    m2.save!

    a = users(:artist1)
    a.save!
    ap = art_pieces(:artpiece1)
    ap.artist_id = a.id
    ap.medium_id = m2.id
    ap.save!
    art_pieces << ap
    ap = art_pieces(:artpiece2)
    ap.artist_id = a.id
    ap.medium_id = m1.id
    ap.save!
    art_pieces << ap
    ap = art_pieces(:artpiece3)
    ap.artist_id = a.id
    ap.medium_id = nil
    ap.save!
    art_pieces << ap
    info = artist_infos(:artist1)
    info.artist_id = a.id
    info.save!
    
    a.artist_info = info
    @artist = a
    @artpieces = art_pieces
  end

  describe "show" do
    context "not logged in" do
      before(:each) do
        get :show, :id => @artpieces.first.id
      end
      it "returns success" do
        response.should be_success
      end
      it "displays art piece" do
        response.should have_tag("#artpiece_title", @artpieces.first.title)
        response.should have_tag("#ap_title", @artpieces.first.title)
      end
      it "has no edit buttons" do
        response.should have_tag("div.edit-buttons", "")
        response.should_not have_tag("div.edit-buttons *")
      end
      it "has a favorite me icon" do
        response.should have_tag('.micro-icon.heart')
      end
      context "piece has been favorited" do
        before do
          ap = @artpieces.first
          users(:aaron).add_favorite ap
          get :show, :id => ap.id
        end
        it "shows the number of favorites"
      end
    end
    context "getting unknown art piece page" do
      it "should redirect to error page" do
        get :show, :id => 'bogusid'
        flash[:error].should match(/couldn't find that art piece/)
        response.should redirect_to '/error'
      end
    end
    context "when logged in as art piece owner" do
      before do
        login_as(@artist)
        @logged_in_artist = @artist
        get :show, :id => @artpieces.first.id
      end
      it_should_behave_like 'logged in artist'
      it "shows edit button" do
        response.should have_tag("div.edit-buttons span#artpiece_edit a", "edit")
      end
      it "shows delete button" do
        response.should have_tag(".edit-buttons #artpiece_del a", "delete")
      end
      it "doesn't show heart icon" do
        response.should_not have_tag('.micro-icon.heart')
      end
    end
    context "when logged in as not artpiece owner" do
      before do
        login_as(users(:aaron))
        get :show, :id => @artpieces.first.id
      end
      it "shows heart icon" do
        response.should have_tag('.micro-icon.heart')
      end
      it "doesn't have edit button" do
        response.should_not have_tag("div.edit-buttons span#artpiece_edit a", "edit")
      end
      it "doesn't have delete button" do
        response.should_not have_tag(".edit-buttons #artpiece_del a", "delete")
      end
    end
  end

  describe "#edit" do
    context "while not logged in" do
      it_should_behave_like "get/post update redirects to login"
      context "post " do
        before do
          post :edit, :id => art_pieces(:artpiece1).id
        end
        it_should_behave_like "redirects to login"
      end
      context "get " do
        before do
          get :edit, :id => art_pieces(:artpiece1).id
        end
        it_should_behave_like "redirects to login"
      end
    end
  end
  
  describe "delete" do
    context "while not logged in" do
      it_should_behave_like 'get/post update redirects to login'
    end
    context "while logged in as not art piece owner" do
      before do
        login_as(users(:aaron))
        post :destroy, :id => art_pieces(:artpiece1).id
      end
      it "returns error page" do
        response.should be_redirect
      end
      it "does not removes that art piece" do
        lambda { ArtPiece.find(art_pieces(:artpiece1).id) }.should_not raise_error ActiveRecord::RecordNotFound
      end

    end

    context "while logged in as art piece owner" do
      before do
        login_as(@artist)
        post :destroy, :id => art_pieces(:artpiece1).id
      end
      it "returns error page" do
        response.should be_redirect
      end
      it "removes that art piece" do
        lambda { ArtPiece.find(art_pieces(:artpiece1).id) }.should raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
