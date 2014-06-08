require 'spec_helper'

describe Admin::MediaController do

  fixtures :media

  let(:admin) { FactoryGirl.create(:artist, :admin, :active) }

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
    context 'as unauthorized' do
      before do
        get :edit, :id => Medium.first
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as admin
        get :edit, :id => Medium.first
      end
      it { expect(response).to be_success }
      it { assigns(:medium).should eql Medium.first }
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
      it { assigns(:medium).should be_a_kind_of Medium }
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
      it { expect{ post :create, :medium => {:name => 'blah'} }.to change(Medium, :count).by(1) }
      it 'redirects back to the new medium show page' do
        post :create, :medium => {:name => 'blah'}
        expect(response).to redirect_to admin_media_path
      end
      it 'renders new on error' do
        post :create, :medium => {:name => nil}
        expect(response).to render_template 'new'
      end
    end
  end

  describe "#update" do
    context 'as unauthorized' do
      before do
        post :update, :id => 'whatever'
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      let(:medium) { Medium.first }
      before do
        login_as admin
      end
      it 'redirects back to the new medium show page' do
        post :update, :id => medium.id, :medium => {:name => 'brand spankin new'}
        expect(response).to redirect_to admin_media_path
      end
      it 'updates the medium' do
        post :update, :id => medium.id, :medium => {:name => 'brand spankin'}
        medium.reload.name.should eql 'brand spankin'
      end
      it 'renders new on error' do
        post :update, :id => medium.id, :medium => {:name => nil}
        expect(response).to render_template 'edit'
      end
    end
  end

  describe '#destroy' do
    context 'as unauthorized' do
      before do
        delete :destroy, :id => Medium.first.id
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as admin
      end
      it "destroys and redirects" do
        expect{
          delete :destroy, :id => Medium.first.id
          expect(response).to redirect_to admin_media_path
        }.to change(Medium,:count).by(-1)
      end
    end
  end

end
