require 'spec_helper'

describe Admin::ArtPieceTagsController do

  let(:user) { FactoryGirl.create(:user, :active) }
  let(:admin) { FactoryGirl.create(:user, :admin, :active) }
  let!(:tags) do
    FactoryGirl.create(:artist, :with_tagged_art)
    FactoryGirl.create_list(:art_piece_tag, 2)
  end
  describe 'not logged in' do
    describe :index do
      before do
        get :index
      end
      it_should_behave_like 'not authorized'
    end
  end
  describe 'logged in as plain user' do
    describe :index do
      before do
        login_as user
        get :index
      end
      it_should_behave_like 'not authorized'
    end
  end

  describe '#index' do

    render_views

    before do
      login_as admin
      get :index
    end

    it_should_behave_like 'logged in as admin'
    it { expect(response).to be_success }
    it 'shows tag frequency' do
      assert_select '.singlecolumn table td.input-name', :match => /1\.0|0\.0/
    end
    it 'shows one entry per existing tag' do
      assert_select 'tr td.ct', :count => ArtPieceTag.count
    end
  end

  describe '#cleanup' do
    before do
      login_as admin
    end
    it 'redirects to art_piece_tags page' do
      get :cleanup
      expect(response).to redirect_to '/admin/art_piece_tags'
    end
    it 'removes empty tags' do
      expect {
        get :cleanup
      }.to change(ArtPieceTag,:count).by(-2)
    end
  end

end

