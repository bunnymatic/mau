require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe SessionsController do
  fixtures :users, :roles
  describe '#new' do
    describe 'as logged out' do
      before do
        get :new
      end
      it_should_behave_like 'returns success'
      it 'fetches the markdown content properly' do
        assigns(:content).should have_key :content
        assigns(:content).should have_key :cmsid
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
end
