# frozen_string_literal: true
require 'rails_helper'
require 'htmlentities'

describe Admin::StudiosController do
  let(:studios) { create_list :studio, 3, :with_artists }
  let(:studio) { studios.first }
  let(:studio2) { studios.last }
  let(:manager) { FactoryGirl.create(:artist, :manager, :active, studio: studio) }
  let(:manager_studio) { manager.studio }
  let(:editor) { FactoryGirl.create(:artist, :editor, :active, studio: studio) }
  let(:admin) { FactoryGirl.create(:artist, :admin, :active, studio: studio) }

  context 'as an admin' do
    before do
      login_as(admin)
    end
    describe '#new' do
      before do
        get :new
      end
      it 'setups up a new studio' do
        expect(assigns(:studio)).to be_a_kind_of Studio
      end
    end

    describe '#create' do
      let(:studio_attrs) { FactoryGirl.attributes_for(:studio, photo: fixture_file_upload('/files/art.png', 'image/png')) }
      it 'setups up a new studio' do
        expect do
          put :create, params: { studio: studio_attrs }
        end.to change(Studio, :count).by(1)
      end
      it 'renders new on failure' do
        expect do
          put :create, params: { studio: { name: '' } }
          expect(response).to render_template 'new'
        end.to change(Studio, :count).by(0)
      end
    end

    describe '#update' do
      it 'updates a studio' do
        post :update, params: { id: studio.to_param, studio: { name: 'new name' } }
        expect(studio.reload.name).to eql 'new name'
      end
      it 'renders edit on failure' do
        post :update, params: { id: studio.to_param, studio: { name: '' } }
        expect(response).to render_template 'edit'
      end
    end

    describe '#reorder' do
      it 'arranges studios in the order specified given studio slugs' do
        new_order = studios.shuffle
        post :reorder, params: { studios: new_order.map(&:slug) }
        expect(Studio.by_position.first).to eql new_order.first
        expect(Studio.by_position.last).to eql new_order.last
      end

      it 'arranges studios in the order specified given studio ids' do
        new_order = studios.shuffle
        post :reorder, params: { studios: new_order.map(&:id) }
        expect(Studio.by_position.first).to eql new_order.first
        expect(Studio.by_position.last).to eql new_order.last
      end

      it 'returns json' do
        post :reorder, params: { studios: studios.shuffle.map(&:slug) }
        expect(response.content_type).to eql 'application/json'
      end
    end
  end

  describe 'destroy' do
    let(:make_destroy_call) do
      delete :destroy, params: { id: studio.to_param }
    end
    describe 'unauthorized' do
      before do
        make_destroy_call
      end
      it_should_behave_like 'not authorized'
    end
    [:editor, :manager].each do |u|
      describe "as #{u}" do
        before do
          # login_as self.send(u)
          make_destroy_call
        end
        it_should_behave_like 'not authorized'
      end
    end
    describe 'as admin' do
      before do
        studios
        login_as(admin)
      end
      it 'deletes the studio' do
        expect do
          make_destroy_call
        end.to change(Studio, :count).by(-1)
      end
      it 'sets artists to indy for all artists in the deleted studio' do
        artist_ids = studio.reload.artists.map(&:id)
        assert(!artist_ids.empty?, 'You need to have a couple artists on that studio in your fixtures')
        make_destroy_call
        users = User.find(artist_ids)
        expect(users.all? { |a| a.studio_id == 0 }).to eq(true), 'Not all the artists were moved into the "Indy" studio'
      end
    end
  end

  # studio manager required endpoints
  [:edit, :unaffiliate_artist].each do |endpoint|
    describe endpoint.to_s do
      describe 'unauthorized' do
        before do
          get endpoint, params: { id: studio }
        end
        it_should_behave_like 'not authorized'
      end
      describe 'as editor' do
        before do
          login_as editor
          get endpoint, params: { id: studio.to_param }
        end
        it_should_behave_like 'not authorized'
      end
      describe 'as manager' do
        before do
          login_as manager
        end
        context 'not my studio' do
          before do
            get endpoint, params: { id: studio2.id }
          end
          it 'redirects to the referrer' do
            expect(response).to redirect_to SHARED_REFERER
          end
          it 'flashes an error' do
            expect(flash[:error]).to match(/not a manager of that studio/)
          end
        end
      end
    end
  end

  describe 'edit' do
    context 'as a manager' do
      before do
        login_as manager
        get :edit, params: { id: manager.studio.to_param }
      end
      it { expect(response).to be_success }
    end
  end

  describe 'unaffiliate_artist' do
    let(:manager_role) { Role.find_by_role('manager') }
    let(:artist) { (studio.artists.active.to_a - [admin]).first }
    let(:non_studio_artist) { studio2.artists.active.first }

    before do
      login_as admin
    end

    context 'artist to unaffiliate is not the logged in artist' do
      it 'removes the artist from the studio' do
        expect do
          post :unaffiliate_artist, params: { id: studio.to_param, artist_id: artist.id }
        end.to change(studio.artists.active, :count).by(-1)
      end
      it 'does not add any studios' do
        expect do
          post :unaffiliate_artist, params: { id: studio.to_param, artist_id: artist.id }
        end.to change(Studio, :count).by(0)
      end
      it 'does nothing if the artist is not in the studio' do
        expect do
          post :unaffiliate_artist, params: { id: studio.to_param, artist_id: non_studio_artist.id }
        end.to change(studio.artists.active, :count).by(0)
      end
      it 'redirects to the studio edit page' do
        post :unaffiliate_artist, params: { id: studio.to_param, artist_id: artist.id }
        expect(response).to redirect_to edit_admin_studio_path(studio)
      end
    end

    context 'artist to unaffiliate is the logged in artist' do
      let(:artist) { admin }
      before do
        # validate fixtures
        expect(admin.studio).to eql studio
      end

      it 'does not let you unaffiliate yourself' do
        post :unaffiliate_artist, params: { id: studio.to_param, artist_id: artist.id }
        expect(response).to redirect_to edit_admin_studio_path(studio)
        expect(artist.studio).to eql studio
      end
    end
  end

  describe 'index' do
    describe 'unauthorized' do
      before do
        get :index
      end
      it_should_behave_like 'not authorized'
    end
    describe 'as editor' do
      before do
        login_as editor
        get :index
      end
      it_should_behave_like 'not authorized'
    end
  end
end
