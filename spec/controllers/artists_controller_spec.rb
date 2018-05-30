# frozen_string_literal: true

require 'rails_helper'
require 'htmlentities'

describe ArtistsController, elasticsearch: true do
  let(:studio) { create :studio }
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:artist) do
    FactoryBot.create(:artist, :with_art,
                      studio: studio,
                      number_of_art_pieces: 3,
                      nomdeplume: nil, firstname: 'joe', lastname: 'ablow')
  end
  let(:artist2) { FactoryBot.create(:artist, :active, studio: studio) }
  let(:without_address) { FactoryBot.create(:artist, :active, :without_address) }
  let(:artists) do
    [artist] + FactoryBot.create_list(:artist, 3, :with_studio, :with_tagged_art, number_of_art_pieces: 1)
  end
  let!(:open_studios_event) { create(:open_studios_event) }
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:artist_info) { artist.artist_info }
  let(:ne_bounds) { Artist::BOUNDS['NE'] }
  let(:sw_bounds) { Artist::BOUNDS['SW'] }

  describe '#index' do
    before do
      artists
      get :index
    end
    it { expect(response).to be_success }
    it 'set the title' do
      expect(assigns(:page_title)).to eql 'Mission Artists - Artists'
    end
  end

  describe '#index roster view' do
    before do
      get :roster
    end
    it { expect(response).to be_success }
    it 'assigns artists' do
      expect(assigns(:roster).artists.length.size).to be >= 2
    end
    it 'set the title' do
      expect(assigns(:page_title)).to eql 'Mission Artists - Artists'
    end
    it 'artists are all active' do
      assigns(:roster).artists.each do |a|
        expect(a.state).to eql 'active'
      end
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

    it 'redirects to edit#events and sets the flash key :registering_for_open_studios' do
      login_as artist
      get :register_for_current_open_studios
      expect(response).to redirect_to edit_artist_path(artist, anchor: 'events')
      expect(flash[:registering_for_open_studios]).to eq true
    end

    it "redirects to your edit page if you're not logged in" do
      get :register_for_current_open_studios
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe '#update' do
    before do
      artist_info.update(open_studios_participation: '')
    end
    context 'while not logged in' do
      context 'with invalid params' do
        before do
          put :update, params: { id: artist.id, user: {} }
        end
        it_should_behave_like 'redirects to login'
      end
      context 'with valid params' do
        before do
          put :update, params: { id: artist.id, user: { firstname: 'blow' } }
        end
        it_should_behave_like 'redirects to login'
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
      context 'update os status' do
        it 'updates artists os status to true' do
          put :update, xhr: true, params: { id: artist, artist: { 'os_participation' => '1' } }
          expect(artist.reload.os_participation[OpenStudiosEvent.current.key]).to eq true
        end

        it 'sets false if artist has no address' do
          without_address.artist_info.update(open_studios_participation: '')
          put :update, xhr: true, params: { id: without_address, commit: 'submit', artist: { 'os_participation' => '1' } }
          expect(without_address.reload.os_participation[OpenStudiosEvent.current.key]).to be_nil
        end
        it 'saves an OpenStudiosSignupEvent when the user sets their open studios status to true' do
          stub_request(:get, Regexp.new("http:\/\/example.com\/openstudios.*"))
          expect do
            put :update, xhr: true, params: { id: artist, commit: 'submit', artist: { 'os_participation' => '1' } }
          end.to change(OpenStudiosSignupEvent, :count).by(1)
        end
      end
      context 'update name and bio' do
        before do
          artist.update_os_participation OpenStudiosEvent.current, true
        end
        it 'does not reset the open studios participation setting' do
          expect do
            attrs = { 'firstname' => 'mr joe', 'artist_info_attributes' => { 'bio' => 'Dolor error praesentium et' } }
            put :update, params: { id: artist, commit: 'submit', artist: attrs }
          end.to_not change(artist, :doing_open_studios?)
        end
      end
    end
  end

  describe '#edit' do
    context 'while not logged in' do
      before do
        get :edit, params: { id: 'blahdeblah' }
      end
      it_should_behave_like 'redirects to login'
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
      it { expect(response).to be_success }
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
      it { expect(response).to be_success }
    end

    context 'while not logged in' do
      before(:each) do
        get :show, params: { id: artist2.id }
      end
      it { expect(response).to be_success }
    end

    describe 'logged in as admin' do
      before do
        login_as admin
        get :show, params: { id: artist.id }
      end
      it { expect(response).to be_success }
    end

    describe 'json' do
      before do
        get :show, params: { id: artist.id, format: 'json' }
      end
      it_should_behave_like 'successful json'
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
    before do
      # stash an artist and art pieces
      @artpieces = artist.art_pieces.map(&:id)
    end
    context 'while logged in' do
      before(:each) do
        login_as(artist)
      end
      [[2, 1, 3], [1, 3, 2], [2, 3, 1]].each do |ord|
        it "returns art_pieces in new order #{ord.inspect}" do
          order1 = ord.map { |idx| @artpieces[idx - 1] }
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
        order1 = [@artpieces[0], @artpieces[2], @artpieces[1]]
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
        order1 = [@artpieces[0], @artpieces[2], @artpieces[1]]
        post :setarrangement, params: { neworder: order1.join(',') }
        expect(response).to redirect_to artist_path(artist)
      end
      it 'does not redirect if request is xhr' do
        order1 = [@artpieces[0], @artpieces[2], @artpieces[1]]
        post :setarrangement, xhr: true, params: { neworder: order1.join(',') }
        expect(response).to be_success
      end
    end
  end

  describe 'logged out' do
    context 'post to set arrangement' do
      before do
        post :setarrangement, params: { neworder: '1,2' }
      end
      it_should_behave_like 'redirects to login'
    end
  end

  describe '#destroyart' do
    let(:art_pieces) { ArtPiece.all.reject { |art| art.artist == artist } }
    let(:art_pieces_for_deletion) do
      Hash[art_pieces.map.with_index { |a, idx| [a.id, idx % 2] }]
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
      it do
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
        login_as artist
      end
      it 'validate fixtures' do
        expect(art_pieces.size).to be >= 2
      end
      it do
        run_destroy destroy_params
        expect(response).to redirect_to artist_path(artist)
      end
      it 'should remove art' do
        expect do
          run_destroy destroy_params
        end.to change(ArtPiece, :count).by(-1 * num_to_dump)
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
    it_should_behave_like 'successful json'
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
