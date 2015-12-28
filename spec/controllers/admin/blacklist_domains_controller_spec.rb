require 'spec_helper'

describe Admin::BlacklistDomainsController do

  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:fan) { FactoryGirl.create(:fan, :active) }

  context 'authorization' do
    describe 'not logged in' do
      describe "#index" do
        before do
          get :index
        end
        it_should_behave_like 'not authorized'
      end
    end
    describe 'logged in as plain user' do
      describe "#index" do
        before do
          login_as fan
          get :index
        end
        it_should_behave_like 'not authorized'
      end
    end
  end

  context 'authorized' do

    let(:domain) { FactoryGirl.create(:blacklist_domain) }

    describe '#new' do
      before do
        login_as admin
        get :new
      end
      it 'assigns a new blacklist domain' do
        expect(assigns(:domain)).to be_a_kind_of BlacklistDomain
        expect(assigns(:domain)).to be_new_record
      end
    end

    describe '#edit' do
      before do
        login_as admin
        get :edit, :id => domain.id
      end
      it 'loads the domain' do
        expect(assigns(:domain)).to eql domain
      end
    end

    describe '#create' do
      before do
        login_as admin
      end
      it 'creates a new blacklist domain' do
        expect{
          post :create, :blacklist_domain => { :domain => 'blah.de.blah.com' }
        }.to change(BlacklistDomain,:count).by(1)
      end
      it 'renders new on failure' do
        expect{
          post :create, :blacklist_domain => { :domain => '' }
          expect(response).to render_template :new
          expect(assigns(:domain).errors).to be_present
        }.to change(BlacklistDomain,:count).by(0)
      end
      it 'sets a notification' do
        post :create, :blacklist_domain => { :domain => 'blah.de.blah.com' }
        expect(flash[:notice]).to be_present
      end
    end

    describe '#update' do
      before do
        login_as admin
      end
      it 'creates a new blacklist domain' do
        put :update, :id => domain.id, :blacklist_domain => { :domain => 'blah.de.blah.com' }
        expect(BlacklistDomain.find(domain.id).domain).to eql 'blah.de.blah.com'
      end
      it 'sets a notification' do
        put :update, :id => domain.id, :blacklist_domain => { :domain => 'blah.de.blah.com' }
        expect(flash[:notice]).to be_present
      end
      it 'renders edit on failure' do
        put :update, :id => domain.id, :blacklist_domain => { :domain => '' }
        expect(response).to render_template :edit
        expect(assigns(:domain).errors).to be_present
      end
    end

    describe '#destroy' do
      before do
        login_as admin
      end
      it 'removes the domain' do
        domain
        expect{
          delete :destroy, :id => domain.id
          expect(BlacklistDomain.where(:id => domain.id)).to be_empty
        }.to change(BlacklistDomain, :count).by(-1)
      end
      it 'sets a notification' do
        delete :destroy, :id => domain.id
        expect(flash[:notice]).to be_present
      end

      it 'redirects to the domains list' do
        delete :destroy, :id => domain.id
        expect(response).to redirect_to admin_blacklist_domains_path
      end
    end

  end



end
