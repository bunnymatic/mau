require 'spec_helper'
describe Admin::RolesController do

  let(:editor) { FactoryGirl.create(:artist, :editor, :active) }
  let(:manager) { FactoryGirl.create(:artist, :manager, :active) }
  let(:admin) { FactoryGirl.create(:artist, :admin, :active) }
  let(:artist) { FactoryGirl.create(:artist, :active) }

  let!(:users) { [editor, manager, admin] }
  let(:manager_role) { manager.roles.first }
  let(:editor_role) { editor.roles.first }
  let(:admin_role) { admin.roles.first }

  describe 'non-admin' do
    [:index,:edit,:show].each do |endpoint|
      context "#{endpoint}" do
        before do
          get endpoint, :id => 'whatever'
        end
        it_should_behave_like 'not authorized'
      end
    end
  end

  describe 'authorized' do
    before do
      login_as admin, :record => true
    end
    describe 'GET index' do
      before do
        get :index
      end
      it 'shows all roles' do
        assigns(:roles).count.should eql Role.count
      end
    end

    [:new, :show, :edit].each do |endpoint|
      describe "GET #{endpoint}" do
        before do
          get endpoint, :id => manager_role.id
        end
        it { expect(response).to be_success }
      end
    end
    describe 'POST update' do
      context 'with good params' do
        it 'adds a role to a user' do
          expect{ post :update, :id => admin_role.id, :user => artist}.to change(artist.roles, :count).by(1)
        end
        it 'is idempotnent' do
          expect{
            post :update, :id => admin_role.id, :user => artist
            post :update, :id => admin_role.id, :user => artist
          }.to change(artist.roles, :count).by(1)
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
          expect{ post :create, :role => {:role => 'new role'} }.to change(Role, :count).by(1)
        end
        it 'redirects to the roles index page' do
          post :create, :role => {:role => 'new role'}
          expect(response).to redirect_to admin_roles_path
        end
      end
      context 'with bad params' do
        it 'does not create a role' do
          expect{ post :create, :role => {:role => ''} }.to change(Role, :count).by(0)
        end
        it 'renders new' do
          post :create, :role => {:role => ''}
          expect(response).to render_template 'new'
        end
        it 'sets errors on role' do
          post :create, :role => {:role => ''}
          assigns(:role).errors.should_not be_empty
        end
      end
    end

    describe '#destroy' do
      context 'with role' do
        it 'removes the role' do
          expect { delete :destroy, :id => manager_role.id }.to change(Role, :count).by(-1)
        end
        it 'removes the role from all users' do
          ru = RolesUser.find_all_by_role_id(manager_role.id)
          expected_change = ru.count
          expect { delete :destroy, :id => manager_role.id }.to change(RolesUser, :count).by(-expected_change)
          artist.reload
          artist.roles.should_not include manager
        end
        it 'redirects to the roles index page' do
          delete :destroy, :id => manager_role.id
          expect(response).to redirect_to admin_roles_path
        end
      end
      context 'with role and user' do
        it 'removes the role association from the user' do
          expect{ delete :destroy, :user_id => editor.id, :id => editor_role.id }.to change(editor.roles, :count).by(-1)
        end
        it 'redirects to the role page' do
          delete :destroy, :user_id => editor.id, :id => editor_role.id
          expect(response).to redirect_to admin_role_path(editor_role)
        end
      end
      context 'with invalid role and user' do
        it 'removes the role association from the user' do
          expect{ delete :destroy, :user_id => 'bogus', :id => editor_role.id }.to change(editor.roles, :count).by(0)
        end
        it 'redirects to the role page' do
          delete :destroy, :user_id => 'bogus', :id => editor_role.id
          expect(response).to redirect_to admin_role_path(editor_role)
          expect(flash[:error]).to be_present
        end
      end
    end
  end

end
