# frozen_string_literal: true

require 'rails_helper'

describe ArtPiecesController do
  let(:medium) { FactoryBot.create(:medium) }
  let(:existing_tag) { FactoryBot.create(:art_piece_tag) }
  let(:tags) { nil }
  let(:art_piece_attributes) do
    FactoryBot.attributes_for(:art_piece,
                              artist: nil,
                              title: 'TheBestArtInTheWorld',
                              medium_id: medium.id,
                              photo: fixture_file_upload('/files/art.png', 'image/jpeg'))
  end
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:artist) { FactoryBot.create(:artist, :with_studio, :with_tagged_art) }
  let(:artist2) { FactoryBot.create(:artist, :with_studio, :with_tagged_art, number_of_art_pieces: 1) }
  let(:art_pieces) { artist.reload.art_pieces }
  let(:art_piece) { art_pieces.first.reload }

  describe '#show' do
    context 'not logged in' do
      context 'format=html' do
        context 'when the artist is active' do
          before do
            get :show, params: { id: art_piece.id }
          end
          it { expect(response).to be_success }
          it 'has a description with the art piece name' do
            expect(assigns(:page_description)).to match(/#{art_piece.title}/)
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
            expected = ['art is the mission', 'art', 'artists', 'san francisco']
            expected.each do |ex|
              expect(keywords).to include ex
            end
          end
        end
      end

      context 'when the artist is not active' do
        it 'reports a missing art piece' do
          artist.update!(state: :pending)
          get :show, params: { id: artist.representative_piece.id }
          expect(response).to redirect_to '/error'
        end
      end

      context 'getting unknown art piece page' do
        it 'should redirect to error page' do
          get :show, params: { id: 'bogusid' }
          expect(flash[:error]).to match(/couldn\'t find that art/)
          expect(response).to redirect_to '/error'
        end
      end
    end
    context 'format=json' do
      before do
        get :show, params: { id: art_piece.id, format: :json }
      end

      it { should redirect_to api_v2_art_piece_path(art_piece.id, format: :json) }
    end
  end

  describe '#create' do
    context 'while not logged in' do
      context 'post ' do
        before do
          post :create, params: { artist_id: 6 }
        end
        it_should_behave_like 'redirects to login'
      end
    end
    context 'while logged in' do
      before do
        login_as artist
      end
      it 'sets a flash message without image' do
        post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes.except(:photo) }
        expect(assigns(:art_piece).errors[:photo]).to be_present
      end
      it 'redirects to user page on cancel' do
        post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes, commit: 'Cancel' }
        expect(response).to redirect_to artist_path(artist)
      end
      it 'renders new on failed save' do
        allow_any_instance_of(ArtPiece).to receive(:valid?).and_return(false)
        post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes }
        expect(response).to render_template 'artists/manage_art'
      end

      context 'with successful save' do
        let(:tags) { "this, that, #{existing_tag.name}" }

        it 'redirects to show page on success' do
          post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes.merge(tags: tags) }
          expect(response).to redirect_to art_piece_path(ArtPiece.find_by(title: art_piece_attributes[:title]))
        end
        it 'creates a piece of art' do
          expect do
            post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes }
          end.to change(ArtPiece, :count).by 1
        end
        it 'sets a flash message on success' do
          post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes }
          expect(flash[:notice]).to eql "You've got new art!"
        end
        it 'flushes the cache' do
          expect_any_instance_of(ArtPiecesController).to receive(:flush_cache)
          post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes }
        end
        it 'publishes a message' do
          expect_any_instance_of(Messager).to receive(:publish)
          post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes }
        end
        it 'correctly adds tags to the art piece' do
          post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes.merge(tags: tags) }
          expect(ArtPiece.last.tags.count).to eql 3
        end
        it 'only adds the new tags' do
          tags
          expect do
            post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes.merge(tags: tags) }
          end.to change(ArtPieceTag, :count).by 2
        end
      end
    end
  end

  describe '#update' do
    context 'while not logged in' do
      context 'post ' do
        before do
          post :update, params: { id: 'whatever' }
        end
        it_should_behave_like 'redirects to login'
      end
    end
    context 'while logged in' do
      before do
        login_as artist
      end
      it 'with bad attributes' do
        post :update, params: { id: art_piece.id, art_piece: { title: '' } }
        expect(response).to render_template 'edit'
        expect(assigns(:art_piece).errors.size).to be >= 1
      end

      it 'redirects to show page on success' do
        post :update, params: { id: art_piece.id, art_piece: { title: 'new title' } }
        expect(response).to redirect_to art_piece
      end
      it 'updates tags given a string of comma separated items' do
        post :update, params: { id: art_piece.id, art_piece: { title: art_piece.title, tags: 'this, that, the other, this, that' } }
        tag_names = art_piece.reload.tags.map(&:name)
        expect(tag_names.size).to eq(3)
        expect(tag_names).to include 'this'
        expect(tag_names).to include 'this'
        expect(tag_names).to include 'the other'
      end
      it 'sets a flash message on success' do
        post :update, params: { id: art_piece.id, art_piece: { title: 'new title' } }
        expect(flash[:notice]).to eql 'The art has been updated.'
      end
      it 'flushes the cache' do
        expect_any_instance_of(ArtPiecesController).to receive(:flush_cache)
        post :update, params: { id: art_piece.id, art_piece: { title: 'new title' } }
      end
      it 'publishes a message' do
        expect_any_instance_of(Messager).to receive(:publish)
        post :update, params: { id: art_piece.id, art_piece: { title: 'new title' } }
      end
      it 'redirects to show page on cancel' do
        post :update, params: { id: art_piece.id, commit: 'Cancel', art_piece: { title: 'new title' } }
        expect(response).to redirect_to art_piece
      end
      it 'redirects to show if you try to edit someone elses art' do
        ap = artist2.art_pieces.first
        post :update, params: { id: ap.id, art_piece: { title: 'new title' } }
        expect(response).to redirect_to(ap)
      end
    end
  end

  describe '#edit' do
    context 'while not logged in' do
      context 'post ' do
        before do
          post :edit, params: { id: art_piece.id }
        end
        it_should_behave_like 'redirects to login'
      end
      context 'get ' do
        before do
          get :edit, params: { id: art_piece.id }
        end
        it_should_behave_like 'redirects to login'
      end
    end
    context 'while logged in' do
      before do
        login_as artist
      end
      context 'get' do
        before do
          get :edit, params: { id: artist2.art_pieces.first.id }
        end
        it "returns error if you don't own the artpiece" do
          expect(response).to redirect_to '/error'
        end
      end
    end
    context 'while logged in as artist owner' do
      before do
        login_as artist
      end
      context 'get ' do
        before do
          get :edit, params: { id: artist.art_pieces.last }
        end
        it { expect(response).to be_success }
      end
    end
  end

  describe '#delete' do
    context 'while not logged in' do
      before do
        post :destroy, params: { id: 'whatever' }
      end
      it_should_behave_like 'redirects to login'
    end
    context 'while logged in as not art piece owner' do
      before do
        art_piece
        login_as fan
      end
      it 'redirects' do
        post :destroy, params: { id: art_piece.id }
        expect(response).to be_redirect
      end
      it 'does not removes that art piece' do
        expect do
          post :destroy, params: { id: art_piece.id }
        end.to change(ArtPiece, :count).by 0
      end
      it 'does not publish a message ' do
        expect_any_instance_of(Messager).to receive(:publish).never
        post :destroy, params: { id: art_piece.id }
      end
    end

    context 'while logged in as art piece owner' do
      before do
        login_as artist
      end
      it 'returns error page' do
        post :destroy, params: { id: art_piece.id }
        expect(response).to be_redirect
      end
      it 'removes that art piece' do
        post :destroy, params: { id: art_piece.id }
        expect { ArtPiece.find(art_piece.id) }.to raise_error ActiveRecord::RecordNotFound
      end
      it 'calls messager.publish' do
        expect_any_instance_of(Messager).to receive(:publish).exactly(:once)
        post :destroy, params: { id: art_piece.id }
      end
    end
  end
end
