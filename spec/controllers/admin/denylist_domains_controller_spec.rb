require 'rails_helper'

describe Admin::DenylistDomainsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:fan) { FactoryBot.create(:fan, :active) }

  context 'authorization' do
    describe 'not logged in' do
      describe '#index' do
        before do
          get :index
        end
        it_behaves_like 'not authorized'
      end
    end
    describe 'logged in as plain user' do
      describe '#index' do
        before do
          login_as fan
          get :index
        end
        it_behaves_like 'not authorized'
      end
    end
  end

  context 'authorized' do
    let(:domain) { FactoryBot.create(:denylist_domain) }

    describe '#new' do
      before do
        login_as admin
        get :new
      end
      it 'assigns a new denylist domain' do
        expect(assigns(:domain)).to be_a_kind_of DenylistDomain
        expect(assigns(:domain)).to be_new_record
      end
    end

    describe '#create' do
      before do
        login_as admin
      end
      it 'creates a new denylist domain' do
        expect do
          post :create, params: { denylist_domain: { domain: 'blah.de.blah.com' } }
        end.to change(DenylistDomain, :count).by(1)
      end
      it 'renders new on failure' do
        expect do
          post :create, params: { denylist_domain: { domain: '' } }
          expect(response).to render_template :new
          expect(assigns(:domain).errors).to be_present
        end.to change(DenylistDomain, :count).by(0)
      end
      it 'sets a notification' do
        post :create, params: { denylist_domain: { domain: 'blah.de.blah.com' } }
        expect(flash[:notice]).to be_present
      end
    end

    describe '#destroy' do
      before do
        login_as admin
      end
      it 'removes the domain' do
        domain
        expect do
          delete :destroy, params: { id: domain.id }
          expect(DenylistDomain.where(id: domain.id)).to be_empty
        end.to change(DenylistDomain, :count).by(-1)
      end
      it 'sets a notification' do
        delete :destroy, params: { id: domain.id }
        expect(flash[:notice]).to be_present
      end

      it 'redirects to the domains list' do
        delete :destroy, params: { id: domain.id }
        expect(response).to redirect_to admin_denylist_domains_path
      end
    end
  end
end
