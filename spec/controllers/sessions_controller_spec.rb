require 'spec_helper'

include AuthenticatedTestHelper

describe SessionsController do
  fixtures :users, :roles, :cms_documents, :roles_users
  describe '#new' do
    describe 'as logged out' do
      before do
        get :new
      end
      it_should_behave_like 'returns success'
      it 'fetches the text for the signup page via markdown' do
        assigns(:cms_content).should have_key :content
        assigns(:cms_content).should have_key :cmsid
      end
    end
    describe 'as logged in' do
      before do
        login_as(:annafizyta)
      end
      it 'should redirect to root' do
        get :new
        response.should redirect_to '/'
      end
    end
  end
  describe '#create' do
    context 'with invalid params' do
      integrate_views
      before do
        post :create
      end
      it_should_behave_like 'returns success'
      it 'should render the new template' do
        response.should render_template 'new'
      end
      it 'fetches the text for the signup page via markdown' do
        assigns(:cms_content).should have_key :content
        assigns(:cms_content).should have_key :cmsid
      end
    end
  end
end
