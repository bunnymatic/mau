require 'spec_helper'
describe RolesController do
  include AuthenticatedTestHelper
  fixtures :roles, :users, :roles_users
  describe 'non-admin' do
    [:index,:edit].each do |endpoint|
      before do
        get endpoint
      end
      it_should_behave_like 'not authorized'
    end
  end
  describe 'authorized' do
    integrate_views
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
      it 'renders an admin layout' do
        response.layout.should eql 'layouts/mau-admin'
      end
      it 'shows a list of managers' do
        assert_select '.manager.role_container .role_members li', :count => 1, :match => 'admin dude'
      end
      it 'shows a list of editors' do
        assert_select '.editor.role_container .role_members li', :count => 1, :match => 'editor dude'
      end
      it 'shows a list of administrators' do
        assert_select '.admin.role_container .role_members li', :count => 2, :match => /admin dude|artist1 Fixture/
      end
    end
    describe 'GET edit' do
      it_should_behave_like 'logged in as admin'
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
  end
end
