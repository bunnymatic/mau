# frozen_string_literal: true
require 'rails_helper'

describe Admin::MediaController do
  let(:admin) { FactoryGirl.create(:artist, :admin, :active) }
  let!(:media) { FactoryGirl.create_list(:medium, 3) }
  let(:medium) { media.first }

  describe '#index' do
    context 'as unauthorized' do
      before do
        get :index
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as admin
        get :index
      end
      it 'returns media' do
        expect(assigns(:media).map(&:id)).to eq Medium.alpha.map(&:id)
      end
    end
  end

  describe "#edit" do
    let(:make_edit_request) do
      get :edit, params: { id: medium }
    end
    context 'as unauthorized' do
      before do
        make_edit_request
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as admin
        make_edit_request
      end
      it { expect(response).to be_success }
      it { expect(assigns(:medium)).to eql medium }
    end
  end

  describe "#new" do
    context 'as unauthorized' do
      before do
        get :new
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as admin
        get :new
      end
      it { expect(response).to be_success }
      it { expect(assigns(:medium)).to be_a_kind_of Medium }
    end
  end

  describe "#create" do
    context 'as unauthorized' do
      before do
        post :create
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as admin
      end
      it 'creates a new medium' do
        expect do
          post :create, params: { medium: {name: 'blah'} }
        end.to change(Medium, :count).by(1)
      end
      it 'redirects back to the new medium show page' do
        post :create, params: { medium: {name: 'blah'} }
        expect(response).to redirect_to admin_media_path
      end
      it 'renders new on error' do
        post :create, params: { medium: {name: nil} }
        expect(response).to render_template 'new'
      end
    end
  end

  describe "#update" do
    context 'as unauthorized' do
      before do
        post :update, params: { id: 'whatever' }
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as admin
      end
      it 'redirects back to the new medium show page' do
        post :update, params: { id: medium.id, medium: {name: 'brand spankin new'} }
        expect(response).to redirect_to admin_media_path
      end
      it 'updates the medium' do
        post :update, params: { id: medium.id, medium: {name: 'brand spankin'} }
        expect(medium.reload.name).to eql 'brand spankin'
      end
      it 'renders new on error' do
        post :update, params: { id: medium.id, medium: {name: nil} }
        expect(response).to render_template 'edit'
      end
    end
  end

  describe '#destroy' do
    let(:make_destroy_call) do
      delete :destroy, params: { id: medium.id }
    end
    context 'as unauthorized' do
      before do
        make_destroy_call
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as admin
      end
      it "destroys and redirects" do
        expect do
          make_destroy_call
          expect(response).to redirect_to admin_media_path
        end.to change(Medium,:count).by(-1)
      end
    end
  end
end
