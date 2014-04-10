require 'spec_helper'

include AuthenticatedTestHelper

def art_piece_attributes(overrides = {})
  { :title => "hot title",
    :description => "super hot description",
    :medium_id => Medium.last,
    :dimensions => "this x that"
  }.merge(overrides)
end

describe ArtPiecesController do

  fixtures :users, :roles_users, :roles
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :media
  fixtures :art_piece_tags
  fixtures :art_pieces_tags

  describe "#show" do
    before do
      @artist = users(:artist1)
      @artpieces = @artist.art_pieces
      ap = @artpieces.first
      ap.tags << ArtPieceTag.last
      ap.tags << ArtPieceTag.last(2).first
      ap.save
    end
    context "not logged in" do
      context "format=html" do
        render_views
        before do
          get :show, :id => @artpieces.first.id
        end
        it_should_behave_like 'returns success'
        it 'has a description with the art piece name' do
          assert_select 'head' do |tag|
            assert_select 'meta[name=description]' do |desc|
              desc.length.should eql 1
              desc[0].attributes['content'].should match /#{@artpieces.first.title}/
            end
            assert_select 'meta[property=og:description]' do |desc|
              desc.length.should eql 1
              desc[0].attributes['content'].should match /#{@artpieces.first.title}/
            end
          end
        end
        it 'has keywords that match the art piece' do
          assert_select 'head meta[name=keywords]' do |keywords|
            keywords.length.should eql 1
            expected = [@artpieces.first.tags + [@artpieces.first.medium]].flatten.compact.map(&:name)
            actual = keywords[0].attributes['content'].split(',').map(&:strip)
            expected.each do |ex|
              actual.should include ex
            end
          end
        end
        it 'include the default keywords' do
          assert_select 'head meta[name=keywords]' do |keywords|
            keywords.length.should eql 1
            expected = ["art is the mission", "art", "artists", "san francisco"]
            actual = keywords[0].attributes['content'].split(',').map(&:strip)
            expected.each do |ex|
              actual.should include ex
            end
          end
        end

        it 'shows the artist name in the sidebar' do
          artist_link = artist_path(@artpieces.first.artist)
          assert_select ".lcol h3 a[href=#{artist_link}]"
          assert_select ".lcol a[href=#{artist_link}] img"
        end

        it 'shows the thumbnail browser' do
          assert_select '#artp_thumb_browser'
        end

        it 'includes proper JSON for the thumblist' do
          assert_select 'script' do |script_tag|
            script_tag.join.should include 'Thumbs.ThumbList ='
            script_tag.join.should include '"path":"/artistdata/'
          end
        end

        it "displays art piece" do
          assert_select("#artpiece_title", @artpieces.first.title)
        end
        if Conf.show_lightbox_feature
          it 'includes the zoom data for big art pieces' do
            ap = @artpieces.first
            assert_select('a.zoom').each do |tag|
              tag.attributes['href'].should eql ap.get_path('large')
            end
          end
        end
        it "has no edit buttons" do
          assert_select("div.edit-buttons", "")
          expect(css_select("div.edit-buttons *")).to be_empty
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
          flash[:error].should match(/couldn\'t find that art/)
          expect(response).to redirect_to '/error'
        end
      end
      context "when logged in as art piece owner" do
        render_views
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
          expect(css_select('.micro-icon.heart')).to be_empty
        end
      end
      context "when logged in as not artpiece owner" do
        render_views
        before do
          login_as(users(:maufan1))
          get :show, :id => @artpieces.first.id
        end
        it_should_behave_like 'two column layout'
        it "shows heart icon" do
          assert_select('.micro-icon.heart')
        end
        it "doesn't have edit button" do
          expect(css_select("div.edit-buttons span#artpiece_edit a")).to be_empty
        end
        it "doesn't have delete button" do
          expect(css_select(".edit-buttons #artpiece_del a")).to be_empty
        end
      end
    end
    context 'format=json' do
      let(:parsed) { JSON.parse(response.body)['art_piece'] }
      let(:tag) { FactoryGirl.create :art_piece_tag, :name => 'my first tag' }
      let(:piece) { ArtPiece.first }
      let(:medium) { Medium.first }

      before do
        piece.medium = medium
        piece.tags << tag
        piece.save!

        get :show, :id => piece.id, :format => :json
      end

      it_should_behave_like 'successful json'

      it 'includes the fields we care about' do
        %w( id filename title description dimensions artist_id
            medium_id year image_height image_width order
            tags medium favorites_count
            image_dimensions image_files artist_name ).each do |expected|
          expect(parsed).to have_key expected
        end
      end

      it 'includes paths to the images' do
        sizes = ['cropped_thumb','large','medium','original', 'small','thumb']
        files = parsed['image_files']
        expect(files.keys.sort).to eql sizes
        sizes.each do |sz|
          expect(files[sz]).to eql piece.get_path(sz)
        end
      end

      it 'includes image dimensions' do
        sizes = ['cropped_thumb','large','medium','original', 'small','thumb']
        dimensions = parsed['image_dimensions']
        expect(dimensions.keys.sort).to eql sizes
        sizes.each do |sz|
          expect(dimensions[sz]).to eql piece.compute_dimensions[sz]
        end
      end

      it 'includes the tags' do
        parsed['tags'].should be_a_kind_of Array
        parsed['tags'].first['name'].should eql 'my first tag'
      end
      it 'includes the artists name' do
        parsed['artist_name'].should eql piece.artist.get_name
      end
      it 'includes the art piece title' do
        parsed['title'].should eql piece.title
      end
      it 'includes the medium' do
        parsed['medium']['name'].should eql medium.name
      end
    end

  end

  describe '#new' do
    before do
      login_as :artist1
    end
    it 'sets a flash for artists with a full portfolio' do
      Artist.any_instance.stub(:max_pieces => 0)
      get :new
      flash.now[:error].should be_present
    end
    it 'assigns all media' do
      get :new
      assigns(:media).should eql Medium.all
    end
    it 'assigns a new art piece' do
      get :new
      assigns(:art_piece).should be_a_kind_of ArtPiece
    end
  end

  describe '#create', :eventmachine => true do
    context "while not logged in" do
      render_views
      context "post " do
        before do
          post :create
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before do
        login_as :joeblogs
      end
      it 'sets a flash message without image' do
        post :create, :art_piece => art_piece_attributes
        assigns(:art_piece).errors[:base].should be_present
      end
      it 'redirects to user page on cancel' do
        post :create, :art_piece => art_piece_attributes, :commit => 'Cancel'
        expect(response).to redirect_to artist_path(users(:joeblogs))
      end
      it 'renders new on failed save' do
        ArtPiece.any_instance.should_receive(:save).and_return(false)
        post :create, :art_piece => art_piece_attributes, :upload => {}
        expect(response).to render_template 'new'
      end
      context 'when image upload raises an error' do
        before do
          ArtPieceImage.any_instance.should_receive(:save).and_raise MauImage::ImageError.new('eat it')
          post :create, :art_piece => art_piece_attributes, :upload => {}
        end
        it 'renders the form again' do
          expect(response).to render_template 'new'
        end
        it 'sets the error' do
          expect(assigns(:art_piece).errors[:base].to_s).to include 'eat it'
        end
      end

      context 'with successful save' do
        before do
          mock_art_piece_image = double('MockArtPieceImage', :save => true)
          ArtPieceImage.should_receive(:new).and_return(mock_art_piece_image)
        end
        it 'redirects to show page on success' do
          post :create, :art_piece => art_piece_attributes, :upload => {}
          expect(response).to redirect_to artist_path(users(:joeblogs))
        end
        it 'sets a flash message on success' do
          post :create, :art_piece => art_piece_attributes, :upload => {}
          flash[:notice].should eql 'Artwork was successfully added.'
        end
        it "flushes the cache" do
          ArtPiecesController.any_instance.should_receive(:flush_cache)
          post :create, :art_piece => art_piece_attributes, :upload => {}
        end
        it 'publishes a message' do
          Messager.any_instance.should_receive(:publish)
          post :create, :art_piece => art_piece_attributes, :upload => {}
        end
      end
    end
  end

  describe '#update', :eventmachine => true do
    context "while not logged in" do
      render_views
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
      it 'with bad attributes' do
        post :update, :id => @ap.id, :art_piece => {:title => ''}
        expect(response).to render_template 'edit'
        expect(assigns(:art_piece).errors).to have_at_least(1).error
      end

      it 'redirects to show page on success' do
        post :update, :id => @ap.id, :art_piece => {:title => 'new title'}
        expect(response).to redirect_to art_piece_path(@ap)
      end
      it 'sets a flash message on success' do
        post :update, :id => @ap.id, :art_piece => {:title => 'new title'}
        flash[:notice].should eql 'Artwork was successfully updated.'
      end
      it "flushes the cache" do
        ArtPiecesController.any_instance.should_receive(:flush_cache)
        post :update, :id => @ap.id, :art_piece => {:title => 'new title'}
      end
      it 'publishes a message' do
        Messager.any_instance.should_receive(:publish)
        post :update, :id => @ap.id, :art_piece => {:title => 'new title'}
      end
      it 'redirects to show page on cancel' do
        post :update, :id => @ap.id, :commit => 'Cancel', :art_piece => {:title => 'new title'}
        expect(response).to redirect_to @ap
      end
      it 'redirects to show if you try to edit someone elses art' do
        ap = ArtPiece.all.detect{|ap| ap.artist != @ap.artist}

        post :update, :id => ap.id, :art_piece => {:title => 'new title'}
        expect(response).to render_template ap
      end

    end
  end

  describe "#edit" do
    context "while not logged in" do
      render_views
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
      render_views
      context "get " do
        before do
          get :edit, :id => art_pieces(:artpiece1).id
        end
        it "returns error if you don't own the artpiece" do
          expect(response).to redirect_to "/error"
        end
        it "sets a flash error" do
          flash[:error].should be_present
        end
      end
    end
    context "while logged in as artist owner" do
      before do
        login_as(users(:artist1))
      end
      render_views
      context "get " do
        before do
          get :edit, :id => art_pieces(:artpiece1).id
        end
        it_should_behave_like 'returns success'
      end
    end

  end

  describe "#delete", :eventmachine => true do
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
      it { expect(response).to be_redirect }
      it "does not removes that art piece" do
        expect{ ArtPiece.find(art_pieces(:artpiece1).id) }.to_not raise_error
      end
      it 'does not publish a message' do
        Messager.any_instance.should_receive(:publish).never
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
        expect(response).to be_redirect
      end
      it "removes that art piece" do
        post :destroy, :id => @ap
        expect{ ArtPiece.find(@ap) }.to raise_error ActiveRecord::RecordNotFound
      end
      it "calls messager.publish" do
        Messager.any_instance.should_receive(:publish).exactly(:once)
        post :destroy, :id => @ap
      end
    end
  end
end
