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
                              photo: fixture_file_upload('art.jpg', 'image/jpeg'))
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
          it { expect(response).to be_successful }
          it 'has a description with the art piece name' do
            expect(assigns(:page_description)).to match(/#{Regexp.quote(art_piece.title)}/)
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
          get :show, params: { id: artist.reload.representative_piece.id }
          expect(response).to redirect_to '/error'
        end
      end

      context 'getting unknown art piece page' do
        it 'should redirect to error page' do
          get :show, params: { id: 'bogusid' }
          expect(flash[:error]).to match(/couldn't find that art/)
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
    before do
      allow(WatcherMailerList).to receive(:first).and_return(
        instance_double(WatcherMailerList, formatted_emails: []),
      )
    end
    context 'while not logged in' do
      context 'post ' do
        before do
          post :create, params: { artist_id: 6 }
        end
        it_behaves_like 'redirects to login'
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
        let(:tags) { ['this', 'that', existing_tag.name] }

        it 'redirects to show page' do
          post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes.merge(tag_ids: tags) }
          expect(response).to redirect_to art_piece_path(ArtPiece.find_by(title: art_piece_attributes[:title]))
        end
        it 'creates a piece of art' do
          expect do
            post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes }
          end.to change(ArtPiece, :count).by 1
        end
        it 'sets a flash message' do
          post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes }
          expect(flash[:notice]).to eql "You've got new art!"
        end
        it 'correctly adds tags to the art piece' do
          post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes.merge(tag_ids: tags) }
          expect(ArtPiece.last.tags.count).to eql 3
        end
        it 'only adds the new tags' do
          tags
          expect do
            post :create, params: { artist_id: artist.id, art_piece: art_piece_attributes.merge(tag_ids: tags) }
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
        it_behaves_like 'redirects to login'
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
        post :update, params: { id: art_piece.id, art_piece: { title: art_piece.title, tag_ids: ['this', 'that', 'the other', 'this', 'that'] } }
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
      it 'redirects to show page on cancel' do
        post :update, params: { id: art_piece.id, commit: 'Cancel', art_piece: { title: 'new title' } }
        expect(response).to redirect_to art_piece
      end
      it 'redirects to show if you try to edit someone elses art' do
        ap = artist2.reload.art_pieces.first
        post :update, params: { id: ap.id, art_piece: { title: 'new title' } }
        expect(response).to redirect_to(ap)
      end
      it 'sets sold_at if sold is set' do
        freeze_time do
          now = Time.current
          post :update, params: { id: art_piece.id, art_piece: { sold: '1', title: 'i got updated' } }
          expect(response).to redirect_to(art_piece)
          art_piece.reload
          expect(art_piece.title).to eq 'i got updated'
          expect(art_piece.reload.sold_at).to eq now
        end
      end
      it 'does not set sold_at if sold is not checked (form sends "0")' do
        post :update, params: { id: art_piece.id, art_piece: { sold: '0', title: 'the new thing' } }
        expect(response).to redirect_to(art_piece)
        art_piece.reload
        expect(art_piece.sold_at).to be_nil
        expect(art_piece.title).to eq 'the new thing'
      end
      it 'unsets sold_at if sold is not checked (form sends "0")' do
        art_piece.update(sold_at: Time.current, title: 'the new thing')
        post :update, params: { id: art_piece.id, art_piece: { sold: '0' } }
        expect(response).to redirect_to(art_piece)
        art_piece.reload
        expect(art_piece.sold_at).to be_nil
        expect(art_piece.title).to eq 'the new thing'
      end
    end
  end

  describe '#edit' do
    context 'while not logged in' do
      context 'post ' do
        before do
          post :edit, params: { id: art_piece.id }
        end
        it_behaves_like 'redirects to login'
      end
      context 'get ' do
        before do
          get :edit, params: { id: art_piece.id }
        end
        it_behaves_like 'redirects to login'
      end
    end
    context 'while logged in' do
      before do
        login_as artist
      end
      context 'get' do
        before do
          get :edit, params: { id: artist2.reload.art_pieces.first.id }
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
          get :edit, params: { id: art_pieces.last }
        end
        it { expect(response).to be_successful }
      end
    end
  end

  describe '#delete' do
    before do
      allow(BryantStreetStudiosWebhook).to receive(:artist_updated)
    end
    context 'while not logged in' do
      before do
        post :destroy, params: { id: 'whatever' }
      end
      it_behaves_like 'redirects to login'
    end
    context 'while logged in as not art piece owner' do
      before do
        art_piece
        login_as fan
      end

      context 'returns unauthorized' do
        before do
          post :destroy, params: { id: art_piece.id }
        end
        it_behaves_like 'not authorized'
      end

      it 'does not removes that art piece' do
        expect do
          post :destroy, params: { id: art_piece.id }
        end.to change(ArtPiece, :count).by 0
      end

      it 'does not post webhook to BSS' do
        post :destroy, params: { id: art_piece.id }
        expect(BryantStreetStudiosWebhook).to_not have_received(:artist_updated)
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
      it 'calls bryant street studios webhook' do
        post :destroy, params: { id: art_piece.id }
        expect(BryantStreetStudiosWebhook).to have_received(:artist_updated).with(art_piece.artist.id)
      end
    end
  end

  describe 'protected .build_page_description' do
    let(:artist) { create(:artist, nomdeplume: 'Heller, Gusikowski and Robel') }
    let(:art_piece) do
      FactoryBot.create(:art_piece,
                        artist:,
                        title: '"an.ä.log dumb > title with " quotes " by mr rogers')
    end

    it 'prove that page description is html safe' do
      expect(described_class.new.send(:build_page_description, art_piece))
        .to eq 'Mission Artists Art : &quot;an.&auml;.log dumb &gt; title with &quot; quotes &quot; by mr rogers by Heller, Gusikowski and Robel'
    end
  end
end
