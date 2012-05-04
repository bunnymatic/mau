require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../controllers_helper')
include AuthenticatedTestHelper

describe ArtPiecesController do

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :media

  before do 
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
    @artist = a
    @artpieces = art_pieces
  end

  describe "#show" do
    context "not logged in" do
      integrate_views
      before do
        get :show, :id => @artpieces.first.id
      end
      it_should_behave_like 'returns success'
      it 'has a description with the art piece name' do
        assert_select 'head' do |tag|
          assert_select 'meta[name=description]' do |desc|
            desc.length.should == 1
            desc[0].attributes['content'].should match /#{@artpieces.first.title}/
          end
          assert_select 'meta[property=og:description]' do |desc|
            desc.length.should == 1
            desc[0].attributes['content'].should match /#{@artpieces.first.title}/
          end
        end
      end
      it 'has keywords that match the art piece' do
        assert_select 'head meta[name=keywords]' do |keywords|
          keywords.length.should == 1
          expected = [@artpieces.first.art_piece_tags + [@artpieces.first.medium]].flatten.map(&:name)
          actual = keywords[0].attributes['content'].split(',').map(&:strip)
          expected.each do |ex|
            actual.should include ex
          end
        end
      end
      it 'include the default keywords' do
        assert_select 'head meta[name=keywords]' do |keywords|
          keywords.length.should == 1
          expected = ["art is the mission", "art", "artists", "san francisco"]
          actual = keywords[0].attributes['content'].split(',').map(&:strip)
          expected.each do |ex|
            actual.should include ex
          end
        end
      end
      it "displays art piece" do
        assert_select("#artpiece_title", @artpieces.first.title)
        assert_select("#ap_title", @artpieces.first.title)
      end
      it "has no edit buttons" do
        assert_select("div.edit-buttons", "")
        response.should_not have_tag("div.edit-buttons *")
      end
      it "has a favorite me icon" do
        assert_select('.micro-icon.heart')
      end
      context "piece has been favorited" do
        before do
          ap = @artpieces.first
          users(:maufan1).add_favorite ap
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
      integrate_views
      before do
        login_as(@artist)
        @logged_in_artist = @artist
        get :show, :id => @artpieces.first.id
      end
      it_should_behave_like 'two column layout'
      it_should_behave_like 'logged in artist'
      it "shows edit button" do
        assert_select("div.edit-buttons span#artpiece_edit a", "edit")
      end
      it "shows delete button" do
        assert_select(".edit-buttons #artpiece_del a", "delete")
      end
      it "doesn't show heart icon" do
        response.should_not have_tag('.micro-icon.heart')
      end
    end
    context "when logged in as not artpiece owner" do
      integrate_views
      before do
        login_as(users(:maufan1))
        get :show, :id => @artpieces.first.id
      end
      it_should_behave_like 'two column layout'
      it "shows heart icon" do
        assert_select('.micro-icon.heart')
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
      integrate_views
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
    context "while logged in" do
      before do
        login_as(users(:joeblogs))
      end
      integrate_views
      context "get " do
        before do
          get :edit, :id => art_pieces(:artpiece1).id
        end
        it "returns error if you don't own the artpiece" do
          response.should redirect_to "/error"
        end
        it "sets a flash error" do
          flash[:error].should be
        end
      end
    end
    context "while logged in as artist owner" do
      before do
        login_as(users(:artist1))
      end
      integrate_views
      context "get " do
        before do
          get :edit, :id => art_pieces(:artpiece1).id
        end
        it_should_behave_like 'returns success'
      end
    end
      
  end
  
  describe "#delete" do
    context "while not logged in" do
      it_should_behave_like 'get/post update redirects to login'
    end
    context "while logged in as not art piece owner" do
      before do
        login_as(users(:maufan1))
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
