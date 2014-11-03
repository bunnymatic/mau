require 'spec_helper'

describe MediaController do
  
  let(:media) { FactoryGirl.create_list(:medium, 4) }
  let(:artists) { FactoryGirl.create_list(:artist, 2, :active) }
  let(:art_pieces) { 
    10.times.map { FactoryGirl.create(:art_piece, medium_id: media.sample.id, artist: artists.sample) }
  }

  before do
    Rails.cache.clear
    art_pieces
  end

  describe "#index" do
    it "redirect to show" do
      get :index
      expect(response).to be_redirect
    end
    context 'with no frequency' do
      before do
        Medium.stub(:frequency => [])
      end
      it "redirect to show first" do
        get :index
        expect(response).to redirect_to Medium.first
      end
    end
  end


  describe "#show" do
    let(:medium) { Artist.active.map(&:art_pieces).flatten.map(&:medium).first }
    context 'for valid medium' do
      render_views
      context 'by artist' do
        before do
          get :show, :id => medium.id, :m => 'a'
        end
        it_should_behave_like 'two column layout'
        it_should_behave_like "not logged in"
        it "page is in artists mode" do
          assigns(:media_presenter).should be_by_artists
        end
        it "assigns pieces" do
          assigns(:pieces).should have_at_least(1).piece
        end
      end
      context 'by art piece' do
        before do
          get :show, :id => medium
        end
        it_should_behave_like 'two column layout'
        it_should_behave_like "not logged in"
        it "page is in pieces mode" do
          assigns(:media_presenter).should be_by_pieces
        end
        it "assigns pieces" do
          assigns(:pieces).should have_at_least(1).piece
        end
        it "assigns all media" do
          assigns(:media).should have_at_least(1).medium
        end
        it "assigns frequency" do
          assigns(:frequency).should have_at_least(1).item
        end
        it "assigns frequency" do
          freq = assigns(:frequency)
          freq.should be_present
        end
        it "draws tag cloud" do
          assert_select('.tagcloud')
        end
        it "tag cloud has items" do
          assert_select('.clouditem')
        end
        it "tag cloud has a selected one" do
          assert_select('.clouditem.tagmatch')
        end
        it "pieces are in order of art_piece updated_date" do
          assigns(:pieces).map(&:updated_at).should be_monotonically_decreasing
        end
      end
    end
  end

end
