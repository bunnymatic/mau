require 'spec_helper'

describe MediaController do

  fixtures :media, :art_pieces, :artist_infos, :users, :roles, :roles_users
  before do

    Rails.cache.stub(:read => nil)

    # media don't exist in a vaccuum
    aps = [:hot,
           :not,
           :h1024w2048,
           :negative_size,
           :artpiece1,
           :artpiece2,
           :artpiece3].map{|a| art_pieces(a)}

    meds = [:medium1, :medium2, :medium3].map{|m| media(m)}

    artists = [:quentin, :artist1, :joeblogs].map{|u| users(u)}

    aps.each_with_index do |ap, idx|
      mid = meds[idx % meds.size].id
      aid = artists[(idx + 2) % artists.size].id
      ap.update_attributes(:artist_id => aid, :medium_id => mid)
    end
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
    context 'for valid medium' do
      render_views
      context 'by artist' do
        before do
          get :show, :id => Medium.first.id, :m => 'a'
        end
        it_should_behave_like 'two column layout'
        it_should_behave_like "not logged in"
        it "page is in artists mode" do
          assigns(:media_presenter).should be_by_artists
        end
      end
      context 'by art piece' do
        before do
          get :show, :id => Medium.first.id
        end
        it_should_behave_like 'two column layout'
        it_should_behave_like "not logged in"
        it "page is in pieces mode" do
          assigns(:media_presenter).should be_by_pieces
        end
        it "assigns pieces" do
          assigns(:pieces).should have_at_least(1).medium
        end
        it "assigns all media" do
          assigns(:media).should have_at_least(1).medium
        end
        it "assigns frequency" do
          assigns(:frequency).should have_at_least(1).item
        end
        it "assigns frequency" do
          freq = assigns(:frequency)
          m2freq = freq.select{|f| f['medium'].to_i == media(:medium1).id}.first
          m2freq['ct'].should eql 1.0
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
