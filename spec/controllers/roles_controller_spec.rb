require 'spec_helper'
describe RolesController do
  include AuthenticatedTestHelper
  fixtures :roles, :users, :roles_users

  let(:jesse) { users(:jesseponce) }

  describe 'non-admin' do
    [:index,:edit,:show].each do |endpoint|
      before do
        get endpoint
      end
      it_should_behave_like 'not authorized'
    end
  end
  describe 'authorized' do
    render_views
    before do
      login_as :admin
    end
    describe 'GET index' do
      before do
        get :index
      end
      it_should_behave_like 'logged in as admin'
      it 'shows all roles' do
        assigns(:roles).count.should eql Role.count
      end
      it { response.should render_template 'layouts/mau-admin' }
      [:manager, :admin, :editor].each do |role|
        it "shows a list of users with role #{role}" do
          rol = roles(role)
          expected = RolesUser.find_all_by_role_id(rol.id).select{|ru| ru.user.active?}
          assert_select ".#{role}.role_container .role_members li", :count => expected.count
        end
      end
    end
    [:show, :edit].each do |endpoint|
      describe "GET #{endpoint}" do
        let(:manager_role) { roles(:manager) }
        before do
          get endpoint, :id => manager_role
        end
        it_should_behave_like 'logged in as admin'
      end
    end
    describe 'POST update' do
      context 'with good params' do
        it 'adds a role to a user' do
          expect{ post :update, :id => roles(:admin), :user => jesse}.to change(jesse.roles, :count).by(1)
        end
        it 'is idempotnent' do
          expect{
            post :update, :id => roles(:admin), :user => jesse
            post :update, :id => roles(:admin), :user => jesse
          }.to change(jesse.roles, :count).by(1)
        end
      end
    end

    describe 'POST create' do
      context 'with good params' do
        it 'creates a role' do
          expect{ post :create, :role => {:role => 'new role'} }.to change(Role, :count).by(1)
        end
        it 'redirects to the roles index page' do
          post :create, :role => {:role => 'new role'}
          response.should redirect_to roles_path
        end
      end
      context 'with bad params' do
        it 'does not create a role' do
          expect{ post :create, :role => {:role => ''} }.to change(Role, :count).by(0)
        end
        it 'renders new' do
          post :create, :role => {:role => ''}
          response.should render_template 'new'
        end
        it 'sets errors on role' do
          post :create, :role => {:role => ''}
          assigns(:role).errors.should_not be_empty
        end
      end
    end

    describe '#destroy' do
      let(:mgr) { roles(:manager) }
      context 'with role' do
        it 'removes the role' do
          expect { delete :destroy, :id => mgr.id }.to change(Role, :count).by(-1)
        end
        it 'removes the role from all users' do
          ru = RolesUser.find_all_by_role_id(mgr.id)
          expected_change = ru.count
          expect { delete :destroy, :id => mgr.id }.to change(RolesUser, :count).by(-expected_change)
          jesse.reload
          jesse.roles.should_not include mgr
        end
        it 'redirects to the roles index page' do
          delete :destroy, :id => mgr.id
          response.should redirect_to roles_path
        end
      end
      context 'with role and user' do
        before do
          @role = roles(:editor)
        end
        it 'removes the role association from the user' do
          expect{ delete :destroy, :user_id => jesse.id, :id => @role.id }.to change(jesse.roles, :count).by(-1)
        end
        it 'redirects to the role page' do
          delete :destroy, :user_id => jesse.id, :id => @role.id
          response.should redirect_to role_path(@role)
        end
      end
    end
  end

end
