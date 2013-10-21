require 'spec_helper'

include AuthenticatedTestHelper

describe BlacklistDomainsController do
  fixtures :users, :roles_users, :roles
  context 'authorization' do
    [:index].each do |endpoint|
      describe 'not logged in' do
        describe endpoint do
          before do
            get endpoint
          end
          it_should_behave_like 'not authorized'
        end
      end
      describe 'logged in as plain user' do
        describe endpoint do
          before do
            login_as(users(:maufan1))
            get endpoint
          end
          it_should_behave_like 'not authorized'
        end
      end
      it "#{endpoint} responds success if logged in as admin" do
        login_as :admin
        get endpoint
        response.should be_success
      end
    end
  end

  context 'authorized' do

    let(:domain) { FactoryGirl.create(:blacklist_domain) }

    describe '#new' do
      before do
        login_as :admin
        get :new
      end
      it 'assigns a new blacklist domain' do
        assigns(:domain).should be_a_kind_of BlacklistDomain
        assigns(:domain).should be_new_record
      end
    end

    describe '#edit' do
      before do
        login_as :admin
        get :edit, :id => domain.id
      end
      it 'loads the domain' do
        assigns(:domain).should eql domain
      end
    end

    describe '#create' do
      before do
        login_as :admin
      end
      it 'creates a new blacklist domain' do
        expect{
          post :create, :blacklist_domain => { :domain => 'blah.de.blah.com' }
        }.to change(BlacklistDomain,:count).by(1)
      end
      it 'renders new on failure' do
        expect{
          post :create, :blacklist_domain => { :domain => '' }
          response.should render_template :new
          assigns(:domain).errors.should be_present
        }.to change(BlacklistDomain,:count).by(0)
      end
      it 'sets a notification' do
        post :create, :blacklist_domain => { :domain => 'blah.de.blah.com' }
        flash[:notice].should be_present
      end
    end

    describe '#update' do
      before do
        login_as :admin
      end
      it 'creates a new blacklist domain' do
        put :update, :id => domain.id, :blacklist_domain => { :domain => 'blah.de.blah.com' }
        BlacklistDomain.find(domain.id).domain.should eql 'blah.de.blah.com'
      end
      it 'sets a notification' do
        put :update, :id => domain.id, :blacklist_domain => { :domain => 'blah.de.blah.com' }
        flash[:notice].should be_present
      end
      it 'renders edit on failure' do
        put :update, :id => domain.id, :blacklist_domain => { :domain => '' }
        response.should render_template :edit
        assigns(:domain).errors.should be_present
      end
    end

    describe '#destroy' do
      before do
        login_as :admin
      end
      it 'removes the domain' do
        domain
        expect{
          delete :destroy, :id => domain.id
          BlacklistDomain.where(:id => domain.id).should be_empty
        }.to change(BlacklistDomain, :count).by(-1)
      end
      it 'sets a notification' do
        delete :destroy, :id => domain.id
        flash[:notice].should be_present
      end

      it 'redirects to the domains list' do
        delete :destroy, :id => domain.id
        response.should redirect_to blacklist_domains_path
      end
    end

  end



end
