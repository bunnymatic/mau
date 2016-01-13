require 'rails_helper'
describe Admin::CmsDocumentsController do

  let(:editor) { FactoryGirl.create(:artist, :editor) }
  let(:cms_document) { FactoryGirl.create(:cms_document, article: "# pr header\n\n## pr header2\n\ncome out to the *preview* receiption") }

  context 'not authorized' do
    [:index, :show, :edit, :update].each do |meth|
      before do
        get meth, :id => 'whatever'
      end
      it_should_behave_like "not authorized"
    end
  end

  context 'authorized' do
    before do
      login_as editor
    end

    describe '#index' do
      before do
        get :index
      end
      it { expect(response).to be_success }
    end

    describe '#show' do
      render_views
      before do
        get :show, :id => cms_document
      end
      it { expect(response).to be_success }
    end

    describe '#edit' do
      before do
        get :edit, :id => cms_document
      end
      it { expect(response).to be_success }
    end

    describe '#new' do
      before do
        get :new
      end
      it { expect(response).to be_success }
    end

    describe '#create' do
      before do
        login_as editor
      end
      it 'creates a new cms document' do
        expect{
          post :create, :cms_document => FactoryGirl.attributes_for(:cms_document)
        }.to change(CmsDocument,:count).by(1)
      end
      it 'renders new on failure' do
        expect{
          post :create, :cms_document => { :page => '', :section => '', :article => ''}
          expect(assigns(:cms_document).errors.size).to be >= 2
        }.to change(CmsDocument,:count).by(0)
      end
      it 'sets a notification' do
        post :create, :cms_document => FactoryGirl.attributes_for(:cms_document)
        expect(flash[:notice]).to be_present
      end
    end

    describe '#update' do
      before do
        login_as editor
      end
      it 'creates a new cms document' do
        put :update, :id => cms_document.id, :cms_document => { :section => 'new_section' }
        expect(CmsDocument.find(cms_document.id).section).to eql 'new_section'
      end
      it 'sets a notification' do
        put :update, :id => cms_document.id, :cms_document => { :section => 'this place' }
        expect(flash[:notice]).to be_present
      end
      it 'renders edit on failure' do
        put :update, :id => cms_document.id, :cms_document => { :page => '' }
        expect(assigns(:cms_document).errors).to be_present
      end
    end


  end

end
