# frozen_string_literal: true

require 'rails_helper'
describe Admin::RolesController do
  let(:editor) { FactoryBot.create(:artist, :editor, :active) }
  let(:manager) { FactoryBot.create(:artist, :manager, :active) }
  let(:admin) { FactoryBot.create(:artist, :admin, :active) }
  let(:artist) { FactoryBot.create(:artist, :active) }

  let(:manager_role) { manager.roles.first }
  let(:editor_role) { editor.roles.first }
  let(:admin_role) { admin.roles.first }

  describe 'non-admin' do
    %i[index edit].each do |endpoint|
      context endpoint.to_s do
        before do
          get endpoint, params: { id: 'whatever' }
        end
        it_behaves_like 'not authorized'
      end
    end
  end

  describe 'authorized' do
    before do
      login_as admin, record: true
    end
    describe 'GET index' do
      before do
        get :index
      end
      it 'shows all roles' do
        expect(assigns(:roles).count).to eql Role.count
      end
    end

    %i[new edit].each do |endpoint|
      describe "GET #{endpoint}" do
        before do
          get endpoint, params: { id: manager_role.id }
        end
        it { expect(response).to be_successful }
      end
    end
    describe 'POST update' do
      context 'with good params' do
        it 'adds a role to a user' do
          expect do
            post :update, params: { id: admin_role.id, user: artist }
          end.to change(artist.roles, :count).by(1)
        end
        it 'is idempotnent' do
          expect do
            post :update, params: { id: admin_role.id, user: artist }
            post :update, params: { id: admin_role.id, user: artist }
          end.to change(artist.roles, :count).by(1)
        end
      end
    end

    describe 'GET new' do
      before do
        get :new
      end
      it 'sets up a new role' do
        expect(assigns(:role)).to be_a_kind_of Role
        expect(assigns(:role)).to be_new_record
      end
    end

    describe 'POST create' do
      context 'with good params' do
        it 'creates a role' do
          expect do
            post :create, params: { role: { role: 'new role' } }
          end.to change(Role, :count).by(1)
        end
        it 'redirects to the roles index page' do
          post :create, params: { role: { role: 'new role' } }
          expect(response).to redirect_to admin_roles_path
        end
      end
      context 'with bad params' do
        it 'does not create a role' do
          expect do
            post :create, params: { role: { role: '' } }
          end.to change(Role, :count).by(0)
        end
        it 'renders new' do
          post :create, params: { role: { role: '' } }
          expect(response).to render_template 'new'
        end
        it 'sets errors on role' do
          post :create, params: { role: { role: '' } }
          expect(assigns(:role).errors).not_to be_empty
        end
      end
    end

    describe '#destroy' do
      before do
        manager_role
        login_as admin
      end
      context 'with role' do
        it 'removes the role' do
          expect do
            delete :destroy, params: { id: manager_role.id }
          end.to change(Role, :count).by(-1)
        end
        it 'removes the role from all users' do
          ru = RolesUser.where(role: manager_role)
          expected_change = ru.count
          expect do
            delete :destroy, params: { id: manager_role.id }
          end.to change(RolesUser, :count).by(-expected_change)
          artist.reload
          expect(artist.roles).not_to include manager
        end
        it 'redirects to the roles index page' do
          delete :destroy, params: { id: manager_role.id }
          expect(response).to redirect_to admin_roles_path
        end
      end
    end
  end
end
