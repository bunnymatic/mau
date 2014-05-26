require 'spec_helper'
describe RolesController do
  include AuthenticatedTestHelper
  fixtures :roles, :users, :roles_users

  let(:jesse) { users(:jesseponce) }
  let(:editor) { roles(:editor) }
  let(:manager) { roles(:manager) }
  let(:admin) { roles(:admin) }

  describe 'non-admin' do
    [:index,:edit,:show].each do |endpoint|
      context "#{endpoint}" do
        before do
          get endpoint
        end
        it_should_behave_like 'not authorized'
      end
    end
  end

  describe 'authorized' do
    render_views
    before do
      login_as :admin, :record => true
    end
    describe 'GET index' do
      before do
        get :index
      end
      it_should_behave_like 'logged in as admin'
      it 'shows all roles' do
        assigns(:roles).count.should eql Role.count
      end
      it { expect(response).to render_template 'layouts/mau-admin' }
      [:manager, :admin, :editor].each do |role|
        it "shows a list of users with role #{role}" do
          rol = roles(role)
          expected = RolesUser.find_all_by_role_id(rol.id).select{|ru| ru.user.active?}
          assert_select ".#{role}.role_container .role_members li", :count => expected.count
        end
      end
    end
    [:new, :show, :edit].each do |endpoint|
      describe "GET #{endpoint}" do
        before do
          get endpoint, :id => manager
        end
        it_should_behave_like 'logged in as admin'
      end
    end
    describe 'POST update' do
      context 'with good params' do
        it 'adds a role to a user' do
          expect{ post :update, :id => admin, :user => jesse}.to change(jesse.roles, :count).by(1)
        end
        it 'is idempotnent' do
          expect{
            post :update, :id => admin, :user => jesse
            post :update, :id => admin, :user => jesse
          }.to change(jesse.roles, :count).by(1)
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
          expect(response).to redirect_to roles_path
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
          expect { delete :destroy, :id => manager.id }.to change(Role, :count).by(-1)
        end
        it 'removes the role from all users' do
          ru = RolesUser.find_all_by_role_id(manager.id)
          expected_change = ru.count
          expect { delete :destroy, :id => manager.id }.to change(RolesUser, :count).by(-expected_change)
          jesse.reload
          jesse.roles.should_not include manager
        end
        it 'redirects to the roles index page' do
          delete :destroy, :id => manager.id
          expect(response).to redirect_to roles_path
        end
      end
      context 'with role and user' do
        it 'removes the role association from the user' do
          expect{ delete :destroy, :user_id => jesse.id, :id => editor.id }.to change(jesse.roles, :count).by(-1)
        end
        it 'redirects to the role page' do
          delete :destroy, :user_id => jesse.id, :id => editor.id
          expect(response).to redirect_to role_path(editor)
        end
      end
      context 'with invalid role and user' do
        it 'removes the role association from the user' do
          expect{ delete :destroy, :user_id => 'bogus', :id => editor.id }.to change(jesse.roles, :count).by(0)
        end
        it 'redirects to the role page' do
          delete :destroy, :user_id => 'bogus', :id => editor.id
          expect(response).to redirect_to role_path(editor)
          expect(flash[:error]).to be_present
        end
      end
    end
  end

end
