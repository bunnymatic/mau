require 'spec_helper'
describe CmsDocumentsController do

  fixtures :cms_documents, :users, :roles, :roles_users

  context 'not authorized' do
    [:index, :show, :edit, :update].each do |meth|
      before do
        get meth, :id => 'whatever'
      end
      it_should_behave_like "not authorized"
    end
  end

  context 'authorized' do
    let(:cms_document) { cms_documents(:os_preview_reception) }
    render_views
    before do
      login_as :admin
    end

    describe '#index' do
      before do
        get :index
      end
      it { expect(response).to be_success }
    end

    describe '#show' do
      before do
        get :show, :id => cms_document
      end
      it { expect(response).to be_success }
      it 'renders the cms data properly' do
        assert_select 'h2', 'pr header2'
      end
    end

    describe '#edit' do
      before do
        get :edit, :id => cms_document
      end
      it { expect(response).to be_success }
      it 'renders the cms preview' do
        assert_select '#processed_markdown.markdown h2', 'pr header2'
      end
      it 'renders the cms edit box' do
        assert_select '.markdown-input textarea', :include => '## pr eader2'
      end
    end

    describe '#new' do
      before do
        get :new
      end
      it { expect(response).to be_success }
    end

    describe '#create' do
      before do
        login_as :admin
      end
      it 'creates a new cms document' do
        expect{
          post :create, :cms_document => FactoryGirl.attributes_for(:cms_document)
        }.to change(CmsDocument,:count).by(1)
      end
      it 'renders new on failure' do
        expect{
          post :create, :cms_document => { :page => '', :section => '', :article => ''}
          expect(response).to render_template 'new_or_edit'
          assigns(:cms_document).errors.should have_at_least(2).errors
        }.to change(CmsDocument,:count).by(0)
      end
      it 'sets a notification' do
        post :create, :cms_document => FactoryGirl.attributes_for(:cms_document)
        flash[:notice].should be_present
      end
    end

    describe '#update' do
      before do
        login_as :admin
      end
      it 'creates a new cms document' do
        put :update, :id => cms_document.id, :cms_document => { :section => 'new_section' }
        CmsDocument.find(cms_document.id).section.should eql 'new_section'
      end
      it 'sets a notification' do
        put :update, :id => cms_document.id, :cms_document => { :section => 'this place' }
        flash[:notice].should be_present
      end
      it 'renders edit on failure' do
        put :update, :id => cms_document.id, :cms_document => { :page => '' }
        expect(response).to render_template :new_or_edit
        assigns(:cms_document).errors.should be_present
      end
    end


  end

end
