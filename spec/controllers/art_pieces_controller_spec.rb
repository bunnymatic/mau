require 'spec_helper'

describe ArtPiecesController do

  let(:medium) { FactoryGirl.create(:medium) }
  let(:art_piece_attributes) { FactoryGirl.attributes_for(:art_piece, artist: nil, medium_id: medium.id) }
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:artist) { FactoryGirl.create(:artist, :with_studio, :with_tagged_art) }
  let(:artist2) { FactoryGirl.create(:artist, :with_studio, :with_tagged_art) }
  let(:art_pieces) { artist.art_pieces }
  let(:art_piece) { art_pieces.first }


  describe "#index" do
    describe 'json' do
      before do
        get :index, format: 'json', artist_id: artist.id
      end
      it_should_behave_like 'successful json'
      it 'returns all active artists' do
        j = JSON.parse(response.body)
        j.count.should eql artist.art_pieces.count
      end
    end
  end

  describe "#show" do
    context "not logged in" do
      context "format=html" do
        context 'when the artist is active' do
          before do
            get :show, id: art_piece.id
          end
          it { expect(response).to be_success }
          it 'has a description with the art piece name' do
            expect(assigns(:page_description)).to match /#{art_piece.title}/
          end
          it 'has keywords that match the art piece' do
            keywords = assigns(:page_keywords)
            expected = [art_piece.tags + [art_piece.medium]].flatten.compact.map(&:name)
            expected.each do |ex|
              expect(keywords).to include ex
            end
          end
          it 'include the default keywords' do
            keywords = assigns(:page_keywords)
            expected = ["art is the mission", "art", "artists", "san francisco"]
            expected.each do |ex|
              expect(keywords).to include ex
            end
          end

          it 'shows the thumbnail browser' do
            assert_select "art-pieces-browser[art-piece-id=#{art_piece.id}]"
          end

        end
      end

      context 'when the artist is not active' do
        it 'reports a missing art piece' do
          artist.update_attribute(:state, 'pending')
          get :show, id: art_piece.id
          expect(response).to redirect_to '/error'
        end
      end

      context "getting unknown art piece page" do
        it "should redirect to error page" do
          get :show, id: 'bogusid'
          flash[:error].should match(/couldn\'t find that art/)
          expect(response).to redirect_to '/error'
        end
      end
      context "when logged in as not artpiece owner" do
        render_views
        before do
          login_as fan
          get :show, id: art_piece.id
        end
        it "doesn't have edit button" do
          expect(css_select(".edit-buttons #artpiece_edit a")).to be_empty
        end
        it "doesn't have delete button" do
          expect(css_select(".edit-buttons #artpiece_del a")).to be_empty
        end
      end
    end
    context 'format=json' do
      let(:parsed) { JSON.parse(response.body)['art_piece'] }
      before do
        get :show, id: art_piece.id, format: :json
      end

      it_should_behave_like 'successful json'

      it 'includes the fields we care about' do
        %w( id filename title dimensions artist_id
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
          expect(files[sz]).to eql art_piece.get_path(sz)
        end
      end

      it 'includes image dimensions' do
        sizes = ['cropped_thumb','large','medium','original', 'small','thumb']
        dimensions = parsed['image_dimensions']
        expect(dimensions.keys.sort).to eql sizes
        sizes.each do |sz|
          expect(dimensions[sz]).to eql art_piece.compute_dimensions[sz]
        end
      end

      it 'includes the tags' do
        parsed['tags'].should be_a_kind_of Array
        parsed['tags'].first['name'].should eql art_piece.tags.first.name
      end
      it 'includes the artists name' do
        parsed['artist_name'].should eql HTMLEntities.new.encode art_piece.artist.fullname, :named, :hexadecimal
      end
      it 'includes the art piece title' do
        parsed['title'].should eql HTMLEntities.new.encode art_piece.title, :named, :hexadecimal
      end
      it 'includes the medium' do
        parsed['medium']['name'].should eql art_piece.medium.name
      end
    end

  end

  describe '#new' do
    before do
      login_as artist
    end
    it 'sets a flash for artists with a full portfolio' do
      Artist.any_instance.stub(max_pieces: 0)
      get :new, artist_id: artist.id
      flash.now[:error].should be_present
    end
    it 'assigns all media' do
      get :new, artist_id: artist.id
      expect(assigns(:media).map(&:id)).to eql Medium.alpha.map(&:id)
    end
    it 'assigns a new art piece' do
      get :new, artist_id: artist.id
      assigns(:art_piece).should be_a_kind_of ArtPiece
    end
  end

  describe '#create', eventmachine: true do
    context "while not logged in" do
      context "post " do
        before do
          post :create, artist_id: 6
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before do
        login_as artist
      end
      it 'sets a flash message without image' do
        post :create, art_piece: art_piece_attributes
        assigns(:art_piece).errors[:base].should be_present
      end
      it 'redirects to user page on cancel' do
        post :create, art_piece: art_piece_attributes, commit: 'Cancel'
        expect(response).to redirect_to artist_path(artist)
      end
      it 'renders new on failed save' do
        ArtPiece.any_instance.should_receive(:valid?).and_return(false)
        post :create, art_piece: art_piece_attributes, upload: {}
        expect(response).to render_template 'new'
      end
      context 'when image upload raises an error' do
        before do
          ArtPieceImage.any_instance.should_receive(:save).and_raise MauImage::ImageError.new('eat it')
          post :create, art_piece: art_piece_attributes, upload: {}
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
          mock_art_piece_image = double('MockArtPieceImage', save: true)
          ArtPieceImage.should_receive(:new).and_return(mock_art_piece_image)
        end
        it 'redirects to show page on success' do
          post :create, art_piece: art_piece_attributes, upload: {}
          expect(response).to redirect_to artist_path(artist)
        end
        it 'sets a flash message on success' do
          post :create, art_piece: art_piece_attributes, upload: {}
          flash[:notice].should eql 'Artwork was successfully added.'
        end
        it "flushes the cache" do
          ArtPiecesController.any_instance.should_receive(:flush_cache)
          post :create, art_piece: art_piece_attributes, upload: {}
        end
        it 'publishes a message' do
          Messager.any_instance.should_receive(:publish)
          post :create, art_piece: art_piece_attributes, upload: {}
        end
      end
    end
  end

  describe '#update', eventmachine: true do
    context "while not logged in" do
      context "post " do
        before do
          post :update, id: 'whatever'
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before do
        login_as artist
      end
      it 'with bad attributes' do
        post :update, id: art_piece.id, art_piece: {title: ''}
        expect(response).to render_template 'edit'
        expect(assigns(:art_piece).errors).to have_at_least(1).error
      end

      it 'redirects to show page on success' do
        post :update, id: art_piece.id, art_piece: {title: 'new title'}
        expect(response).to redirect_to art_piece
      end
      it 'updates tags given a string of comma separated items' do
        post :update, id: art_piece.id, art_piece: {tags: 'this, that, the other, this, that'}
        tag_names = art_piece.reload.tags.map(&:name)
        expect(tag_names).to have(3).tags
        expect(tag_names).to include 'this'
        expect(tag_names).to include 'this'
        expect(tag_names).to include 'the other'
      end
      it 'sets a flash message on success' do
        post :update, id: art_piece.id, art_piece: {title: 'new title'}
        flash[:notice].should eql 'Artwork was successfully updated.'
      end
      it "flushes the cache" do
        ArtPiecesController.any_instance.should_receive(:flush_cache)
        post :update, id: art_piece.id, art_piece: {title: 'new title'}
      end
      it 'publishes a message' do
        Messager.any_instance.should_receive(:publish)
        post :update, id: art_piece.id, art_piece: {title: 'new title'}
      end
      it 'redirects to show page on cancel' do
        post :update, id: art_piece.id, commit: 'Cancel', art_piece: {title: 'new title'}
        expect(response).to redirect_to art_piece
      end
      it 'redirects to show if you try to edit someone elses art' do
        ap = artist2.art_pieces.first
        post :update, id: ap.id, art_piece: {title: 'new title'}
        expect(response).to render_template ap
      end

    end
  end

  describe "#edit" do
    context "while not logged in" do
      context "post " do
        before do
          post :edit, id: art_piece.id
        end
        it_should_behave_like "redirects to login"
      end
      context "get " do
        before do
          get :edit, id: art_piece.id
        end
        it_should_behave_like "redirects to login"
      end
    end
    context "while logged in" do
      before do
        login_as artist
      end
      context "get " do
        before do
          get :edit, id: artist2.art_pieces.first.id
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
        login_as artist
      end
      context "get " do
        before do
          get :edit, id: artist.art_pieces.last
        end
        it { expect(response).to be_success }
      end
    end

  end

  describe "#delete", eventmachine: true do
    context "while not logged in" do
      before do
        post :destroy, id: 'whatever'
      end
      it_should_behave_like 'redirects to login'
    end
    context "while logged in as not art piece owner" do
      before do
        art_piece
        login_as fan
      end
      it 'redirects' do
        post :destroy, id: art_piece.id
        expect(response).to be_redirect
      end
      it "does not removes that art piece" do
        expect {
          post :destroy, id: art_piece.id
        }.to change(ArtPiece, :count).by 0
      end
      it "does not publish a message " do
        Messager.any_instance.should_receive(:publish).never
        post :destroy, id: art_piece.id
      end

    end

    context "while logged in as art piece owner" do
      before do
        login_as artist
        @ap = art_piece.id
      end
      it "returns error page" do
        post :destroy, id: @ap
        expect(response).to be_redirect
      end
      it "removes that art piece" do
        post :destroy, id: @ap
        expect{ ArtPiece.find(@ap) }.to raise_error ActiveRecord::RecordNotFound
      end
      it "calls messager.publish" do
        Messager.any_instance.should_receive(:publish).exactly(:once)
        post :destroy, id: @ap
      end
    end
  end
end
