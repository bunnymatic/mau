# frozen_string_literal: true
require 'rails_helper'
describe Admin::ArtPieceTagsController do
  let(:user) { FactoryGirl.create(:user, :active) }
  let(:admin) { FactoryGirl.create(:user, :admin, :active) }
  let!(:artist) { FactoryGirl.create(:artist, :with_tagged_art) }
  let!(:tags) { FactoryGirl.create_list(:art_piece_tag, 2) }

  describe 'not logged in' do
    describe '#index' do
      before do
        get :index
      end
      it_should_behave_like 'not authorized'
    end
  end
  describe 'logged in as plain user' do
    describe '#index' do
      before do
        login_as user
        get :index
      end
      it_should_behave_like 'not authorized'
    end
  end

  describe '#index' do
    before do
      login_as admin
      get :index
    end
    it { expect(response).to be_success }
  end

  describe "#destroy" do
    let!(:tag) { ArtPiece.all.map(&:tags).flatten.compact.first }
    before do
      login_as admin
    end
    it "removes the tag" do
      expect do
        delete :destroy, params: { id: tag.id }
      end.to change(ArtPieceTag, :count).by(-1)
      expect(ArtPieceTag.where(id: tag.id)).to be_empty
    end
    it "clears the cache" do
      expect(ArtPieceTagService).to receive :flush_cache
      delete :destroy, params: { id: tag.id }
    end
    it "redirects to list of all tags" do
      delete :destroy, params: { id: tag.id }
      expect(response).to redirect_to admin_art_piece_tags_path
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
      expect do
        get :cleanup
      end.to change(ArtPieceTag,:count).by(-2)
    end
  end
end
