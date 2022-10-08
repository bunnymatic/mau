require 'rails_helper'
require 'htmlentities'

describe ArtistsController, elasticsearch: :stub do
  let(:artist) do
    FactoryBot.create(:artist,
                      :with_art,
                      studio: studio,
                      number_of_art_pieces: number_of_art_pieces,
                      nomdeplume: nil,
                      firstname: 'joe',
                      lastname: 'ablow')
  end
  let(:studio) { create :studio }
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:number_of_art_pieces) { 1 }
  let(:artist_info) { artist.artist_info }
  let(:artist2) { FactoryBot.create(:artist, :active, studio: studio) }
  let(:artists) do
    [artist] + FactoryBot.create_list(:artist, 2, :with_studio, :with_tagged_art, number_of_art_pieces: 1)
  end
  let(:open_studios_event) { create(:open_studios_event) }
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:ne_bounds) { Artist::BOUNDS['NE'] }
  let(:sw_bounds) { Artist::BOUNDS['SW'] }

  describe '#index' do
    let(:query_params) { {} }
    before do
      mock_gallery = instance_double(
        ArtistsGallery,
      )
      allow(ArtistsGallery).to receive(:letters).and_return(%w[b c])
      allow(ArtistsGallery).to receive(:new).and_return(mock_gallery)
      get :index, params: query_params
    end
    it { expect(response).to be_successful }
    it 'set the title' do
      expect(assigns(:page_title)).to eql 'Mission Artists - Artists'
    end
    it 'sets up the gallery with the right params' do
      expect(ArtistsGallery).to have_received(:new).with(
        os_only: false, letter: 'b', ordering: :lastname, current_page: 0,
      )
    end

    context 'with query params' do
      let(:query_params) do
        { o: true, l: 'd', p: 5, s: :firstname }
      end
      it 'sets up the gallery with the right params' do
        expect(ArtistsGallery).to have_received(:new).with(
          os_only: true, letter: 'd', ordering: 'firstname', current_page: 5,
        )
      end
    end
  end

  describe '#index roster view' do
    let(:mock_roster) { instance_double(ArtistsRoster, artists: build_stubbed_list(:artist, 1)) }
    before do
      allow(ArtistsRoster).to receive(:new).and_return(mock_roster)
      allow(PageInfoService).to receive(:title).and_return('the title')
      get :roster
    end
    it { expect(response).to be_successful }
    it 'set the title' do
      expect(assigns(:page_title)).to eql 'the title'
      expect(PageInfoService).to have_received(:title).with('Artists')
    end
  end

  describe '#my_profile' do
    it "redirects to your edit page if you're logged in" do
      login_as artist
      get :my_profile
      expect(response).to redirect_to edit_artist_path(artist, anchor: 'events')
    end

    it "redirects to your edit page if you're not logged in" do
      get :my_profile
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe '#register_for_current_open_studios' do
    it 'redirects fans to their home page with a nice message' do
      login_as fan
      get :register_for_current_open_studios
      expect(response).to redirect_to user_path(fan)
      expect(flash['error']).to include "must have an Artist's account"
    end

    it 'redirects to edit#events' do
      login_as artist
      get :register_for_current_open_studios
      expect(response).to redirect_to edit_artist_path(artist, anchor: 'events')
    end

    it "redirects to your edit page if you're not logged in" do
      get :register_for_current_open_studios
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe '#update' do
    context 'while not logged in' do
      context 'with invalid params' do
        before do
          put :update, params: { id: artist.id, user: {} }
        end
        it_behaves_like 'redirects to login'
      end
      context 'with valid params' do
        before do
          put :update, params: { id: artist.id, user: { firstname: 'blow' } }
        end
        it_behaves_like 'redirects to login'
      end
    end
    context 'while logged in' do
      let(:old_bio) { artist_info.bio }
      let(:new_bio) { 'this is the new bio' }
      let(:artist_info_attrs) { { bio: new_bio } }
      before do
        login_as(artist, record: true)
      end
      context 'submit' do
        context 'post with new bio data' do
          it 'redirects to to edit page' do
            put :update, params: { id: artist, commit: 'submit', artist: { artist_info_attributes: artist_info_attrs } }
            expect(flash[:notice]).to eql 'Your profile has been updated'
            expect(response).to redirect_to(edit_artist_path(artist))
          end
          it 'publishes an update message' do
            mock_messagers = Array.new(2) do
              mock_messager = instance_double(Messager)
              expect(mock_messager).to receive(:publish)
              mock_messager
            end
            expect(Messager).to receive(:new).and_return(*mock_messagers)
            put :update, params: { id: artist, commit: 'submit', artist: { artist_info_attributes: artist_info_attrs } }
          end
        end
      end
      context 'cancel post with new bio data' do
        before do
          put :update, params: { id: artist, commit: 'cancel', artist: { artist_info_attributes: artist_info_attrs } }
        end
        it 'redirects to user page' do
          expect(response).to redirect_to(user_path(artist))
        end
        it 'should have no flash notice' do
          expect(flash[:notice]).to be_nil
        end
        it "shouldn't change anything" do
          expect(artist.bio).to eql old_bio
        end
      end
      context 'update address' do
        let(:artist_info_attrs) { { street: '100 main st' } }
        let(:street) { artist_info_attrs[:street] }

        before do
        end

        it 'contains flash notice of success' do
          put :update, params: { id: artist, commit: 'submit', artist: { artist_info_attributes: artist_info_attrs } }
          expect(flash[:notice]).to eql 'Your profile has been updated'
        end
        it 'updates user address' do
          put :update, params: { id: artist, commit: 'submit', artist: { studio_id: nil, artist_info_attributes: artist_info_attrs } }
          expect(artist.address.to_s).to include street
        end
        it 'publishes an update message' do
          mock_messagers = Array.new(2) do
            mock_messager = instance_double(Messager)
            expect(mock_messager).to receive(:publish)
            mock_messager
          end
          expect(Messager).to receive(:new).and_return(*mock_messagers)
          put :update, params: { id: artist, commit: 'submit', artist: { artist_info_attributes: { street: 'wherever' } } }
        end
      end
    end
  end

  describe '#edit' do
    context 'while not logged in' do
      before do
        get :edit, params: { id: 'blahdeblah' }
      end
      it_behaves_like 'redirects to login'
    end
    context 'while logged in as a fan' do
      before do
        login_as fan
        get :edit, params: { id: fan.to_param }
      end
      it { should redirect_to edit_user_path(fan) }
    end

    context 'while logged in' do
      before do
        artist.update(facebook: 'example.com/facebooklink', blog: 'example.com/bloglink')
        login_as artist
        get :edit, params: { id: artist.to_param }
      end
      it { expect(response).to be_successful }
    end
  end

  describe '#show' do
    it 'cant see a suspended artist' do
      artist.update(state: :suspended)
      get :show, params: { id: artist.id }
      expect(flash[:error]).to be_present
      expect(response).to redirect_to artists_path
    end

    it 'cant find an fan' do
      get :show, params: { id: fan.id }
      expect(response).to redirect_to artists_path
    end

    context 'while not logged in' do
      before(:each) do
        get :show, params: { id: artist2.id }
      end
      it { expect(response).to be_successful }
    end

    context 'while not logged in' do
      before(:each) do
        get :show, params: { id: artist2.id }
      end
      it { expect(response).to be_successful }
    end

    describe 'logged in as admin' do
      before do
        login_as admin
        get :show, params: { id: artist.id }
      end
      it { expect(response).to be_successful }
    end
  end

  # describe 'qrcode' do
  #   let(:file_double) {
  #     double("InputFile", read: 'the data from the file').as_null_object
  #   }
  #   before do
  #     allow(MojoMagick).to receive(:raw_command).and_return(true)
  #     FileUtils.mkdir_p File.join(Rails.root,'public','artistdata', artist.id.to_s , 'profile')
  #     FileUtils.mkdir_p File.join(Rails.root,'artistdata', artist.id.to_s , 'profile')
  #   end
  #   it 'generates a png if you ask for one' do
  #     allow(File).to receive(:open).and_return(file_double)
  #     allow(@controller).to receive(:render)
  #     expect(@controller).to receive(:send_data)
  #     get :qrcode, id: artist.id, format: 'png'
  #     expect(response.content_type).to eql 'image/png'
  #   end
  #   it 'redirects to the png if you ask without format' do
  #     allow(File).to receive(:open).and_return(file_double)
  #     allow(@controller).to receive(:render)
  #     get :qrcode, id: artist.id
  #     expect(response).to redirect_to '/artistdata/' + artist.id.to_s + '/profile/qr.png'
  #   end
  #   it 'returns show with flash if the artist has been deleted' do
  #     artist.update_attribute(:state, 'deleted')
  #     get :qrcode, id: artist.id
  #     expect(flash[:error]).to be_present
  #   end
  #   it 'returns show with flash if the artist has been suspended' do
  #     artist.update_attribute(:state, 'suspended')
  #     get :qrcode, id: artist.id
  #     expect(flash[:error]).to be_present
  #   end
  # end

  describe '#setarrangement' do
    let(:artist) do
      FactoryBot.create(:artist,
                        :with_art,
                        studio: studio,
                        number_of_art_pieces: number_of_art_pieces,
                        nomdeplume: nil,
                        firstname: 'joe',
                        lastname: 'ablow')
    end
    let(:number_of_art_pieces) { 3 }
    let(:art_piece_ids) { artist.art_pieces.pluck(:id) }

    context 'while logged in' do
      before(:each) do
        login_as(artist)
      end
      it 'returns art_pieces in new order' do
        [[2, 1, 3], [1, 3, 2], [2, 3, 1]].each do |ord|
          order1 = ord.map { |idx| art_piece_ids[idx - 1] }
          expect(artist.art_pieces.map(&:id)).not_to eql order1
          post :setarrangement, params: { neworder: order1.join(',') }
          expect(response).to redirect_to artist_url(artist)
          aps = Artist.find(artist.id).art_pieces
          expect(aps.map(&:id)).to eql order1
          expect(aps[0].artist.representative_piece.id).to eq(aps[0].id)
        end
      end

      it 'publishes a message to the Messager that something happened' do
        mock_messager = instance_double(Messager)
        expect(mock_messager).to receive(:publish)
        expect(Messager).to receive(:new).and_return(mock_messager)
        order1 = [art_piece_ids[0], art_piece_ids[2], art_piece_ids[1]]
        post :setarrangement, params: { neworder: order1.join(',') }
      end

      it 'sets a flash and redirects to the artist page with invalid params' do
        post :setarrangement
        expect(response).to redirect_to(artist_path(artist))
        expect(flash[:error]).to be_present
      end

      it 'does not rearrange art if cancel is pressed' do
        order1 = artist.art_pieces.map(&:id)
        post :setarrangement, params: { neworder: [order1.last] + order1[0..-2], submit: 'cancel' }
        expect(artist.art_pieces.map(&:id)).to eql order1
      end
      it 'redirects to the artists page' do
        order1 = [art_piece_ids[0], art_piece_ids[2], art_piece_ids[1]]
        post :setarrangement, params: { neworder: order1.join(',') }
        expect(response).to redirect_to artist_path(artist)
      end
      it 'does not redirect if request is xhr' do
        order1 = [art_piece_ids[0], art_piece_ids[2], art_piece_ids[1]]
        post :setarrangement, xhr: true, params: { neworder: order1.join(',') }
        expect(response).to be_successful
      end
    end
  end

  describe 'logged out' do
    context 'post to set arrangement' do
      before do
        post :setarrangement, params: { neworder: '1,2' }
      end
      it_behaves_like 'redirects to login'
    end
  end

  describe '#destroyart' do
    let(:number_of_art_pieces) { 2 }
    let(:art_pieces) { ArtPiece.all.reject { |art| art.artist == artist } }
    let(:art_pieces_for_deletion) do
      art_pieces.map.with_index { |a, idx| [a.id, idx % 2] }.to_h
    end
    let(:destroy_params) { { params: { art: art_pieces_for_deletion } } }
    let(:num_to_dump) { art_pieces_for_deletion.values.select { |v| v == 1 }.count }

    def run_destroy(params = nil)
      post :destroyart, params || { params: {} }
    end

    context 'with no args' do
      before do
        login_as artist
        run_destroy
      end
      it { expect(response).to redirect_to artist_path(artist) }
    end

    context 'when trying to destroy art that is not yours' do
      before do
        artist2
        login_as artist
      end
      it 'redirects to artist path' do
        run_destroy
        expect(response).to redirect_to artist_path(artist)
      end
      it 'should not remove art' do
        expect do
          run_destroy destroy_params
        end.to_not change(ArtPiece, :count)
      end
    end

    context 'when trying to destroy art that is yours' do
      let(:art_pieces) { artist.art_pieces }
      before do
        # For some reason the elasticsearch mocks were not working as of
        # rspec 3.10, so we just mock things higher for this test
        allow(ArtPiece).to receive(:where).and_return(double('ArRelation', destroy_all: true))
        login_as artist
        run_destroy destroy_params
      end
      it 'redirects to the artist path' do
        expect(response).to redirect_to artist_path(artist)
      end
      it 'should remove art' do
        expected_where_clause = {
          artist_id: artist.id,
          id: art_pieces_for_deletion.select { |_id, del| del == 1 }.keys.map(&:to_s),
        }
        expect(ArtPiece).to have_received(:where).with(expected_where_clause)
        expect(ArtPiece.where).to have_received(:destroy_all)
      end
    end
  end

  describe '#manage_art' do
    before do
      login_as artist
    end
    it 'assigns a new art piece' do
      get :manage_art, params: { id: artist.id }
      expect(assigns(:art_piece)).to be_a_kind_of ArtPiece
    end
  end

  describe '#suggest' do
    before do
      Rails.cache.clear
      get :suggest, params: { q: artist.firstname[0..2] }
    end
    it_behaves_like 'successful json'
    it 'returns a hash with a list of artists' do
      j = JSON.parse(response.body)
      expect(j).to be_a_kind_of Array
      expect(j.first.key?('info')).to be
      expect(j.first.key?('value')).to be
    end
    it 'list of artists matches the input parameter' do
      j = JSON.parse(response.body)
      expect(j).to be_a_kind_of Array
      expect(j.size).to eq(1)
      expect(j.first['value']).to eql artist.get_name
    end
  end
end
