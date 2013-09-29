require 'spec_helper'
describe CmsDocumentsController do

  include AuthenticatedTestHelper

  fixtures :cms_documents, :users

  [:index, :show, :edit, :update].each do |meth|
    before do
      get meth
    end
    it_should_behave_like "not authorized"
  end

  context 'authorized' do
    render_views
    before do
      login_as :admin
    end

    describe '#index' do
      before do
        get :index
      end
      it { response.should be_success }
    end

    describe '#show' do
      before do
        get :show, :id => cms_documents(:os_preview_reception)
      end
      it { response.should be_success }
      it 'renders the cms data properly' do
        assert_select 'h2', 'pr header2'
      end
    end

    describe '#edit' do
      before do
        get :edit, :id => cms_documents(:os_preview_reception)
      end
      it { response.should be_success }
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
      it { response.should be_success }
    end

  end

end
