require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../controllers_helper')
include AuthenticatedTestHelper

def art_piece_attributes(overrides = {})
  { :title => "hot title",
    :description => "super hot description",
    :medium_id => Medium.last,
    :dimensions => "this x that"
  }.merge(overrides)
end

describe ArtPiecesController do

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :media
  fixtures :art_piece_tags
  fixtures :art_pieces_tags

  describe "#show" do
    before do
      @artist = users(:artist1)
      @artpieces = @artist.art_pieces
    end
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
          expected = [@artpieces.first.art_piece_tags + [@artpieces.first.medium]].flatten.compact.map(&:name)
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
      it 'includes the zoom data for big art pieces' do
        ap = @artpieces.first
        assert_select('a.zoom').each do |tag|
          tag.attributes['data-image'].should eql ap.get_path('original')
          tag.attributes['data-imagewidth'].should be
          tag.attributes['data-imageheight'].should be
        end
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
        it "shows the number of favorites" do
          assert_select '#num_favorites', 1
        end
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

  describe '#create' do
    context "while not logged in" do
      integrate_views
      context "post " do
        before do
          post :create
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before do
        ArtPieceImage.expects(:save).returns(true)
        login_as :joeblogs
      end
      it 'redirects to show page on success' do
        post :create, :art_piece => art_piece_attributes, :upload => {}
        response.should redirect_to artist_path(users(:joeblogs))
      end
      it 'sets a flash message on success' do
        post :create, :art_piece => art_piece_attributes, :upload => {}
        flash[:notice].should == 'Artwork was successfully added.'
      end
      it "flushes the cache" do
        ArtPiecesController.any_instance.expects(:flush_cache)
        post :create, :art_piece => art_piece_attributes, :upload => {}
      end
      it 'publishes a message' do
        Messager.any_instance.expects(:publish)
        post :create, :art_piece => art_piece_attributes, :upload => {}
      end
    end
  end

  describe '#update' do
    context "while not logged in" do
      integrate_views
      context "post " do
        before do
          post :update
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before do
        @ap = ArtPiece.first
        u = @ap.artist
        login_as u
      end
      it 'redirects to show page on success' do
        post :update, :id => @ap.id, :art_piece => {:title => 'new title'}
        response.should redirect_to art_piece_path(@ap)
      end
      it 'sets a flash message on success' do
        post :update, :id => @ap.id, :art_piece => {:title => 'new title'}
        flash[:notice].should == 'Artwork was successfully updated.'
      end
      it "flushes the cache" do
        ArtPiecesController.any_instance.expects(:flush_cache)
        post :update, :id => @ap.id, :art_piece => {:title => 'new title'}
      end
      it 'publishes a message' do
        Messager.any_instance.expects(:publish)
        post :update, :id => @ap.id, :art_piece => {:title => 'new title'}
      end
    end
  end    

  describe "#edit" do
    context "while not logged in" do
      integrate_views
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
      before do
        post :destroy
      end
      it_should_behave_like 'redirects to login'
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
      it 'does not publish a message' do
        Messager.any_instance.expects(:publish).never
        post :destroy, :id => art_pieces(:artpiece1).id
      end

    end

    context "while logged in as art piece owner" do
      before do
        artist = users(:artist1)
        login_as :artist1
        @ap = artist.art_pieces.first.id
      end
      it "returns error page" do
        post :destroy, :id => @ap
        response.should be_redirect
      end
      it "removes that art piece" do
        post :destroy, :id => @ap
        lambda { ArtPiece.find(@ap) }.should raise_error ActiveRecord::RecordNotFound
      end
      it "calls messager.publish" do
        Messager.any_instance.expects(:publish).times(1)
        post :destroy, :id => @ap
      end
    end
  end
end
