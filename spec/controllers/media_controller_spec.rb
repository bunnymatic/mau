require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MediaController do
  
  fixtures :media
  fixtures :art_pieces
  fixtures :artist_infos
  fixtures :users
  before do
    
    Rails.cache.stubs(:read).returns(nil)

    # media don't exist in a vaccuum
    aps = []
    aps << art_pieces(:hot)
    aps << art_pieces(:not)
    aps << art_pieces(:h1024w2048)
    aps << art_pieces(:negative_size)
    aps << art_pieces(:artpiece1)
    aps << art_pieces(:artpiece2)
    aps << art_pieces(:artpiece3)
    
    meds = []
    meds << media(:medium1)
    meds << media(:medium2)
    meds << media(:medium3)

    artists = []
    artists << users(:quentin)
    artists << users(:artist1)
    artists << users(:joeblogs)

    aps.each_with_index do |ap, idx|
      mid = meds[idx % meds.size].id
      aid = artists[(idx + 2) % artists.size].id
      ap.artist_id = aid
      ap.medium_id = mid
      ap.save
    end
  end
    
  describe "#index" do
    it "redirect to show" do
      get :index
      response.should be_redirect
    end
  end
  describe "#show" do
    integrate_views
    before do
      get :show, :id => Medium.first.id
    end
    it_should_behave_like 'two column layout'
    it_should_behave_like "not logged in"
    it "assigns results_mode p" do
      assigns(:results_mode).should == 'p'
    end
    it "assigns pieces" do
      assigns(:pieces).should have_at_least(1).medium
    end
    it "assigns all media" do
      assigns(:media).should have_at_least(1).medium
    end
    it "assigns frequency" do
      assigns(:freq).should have_at_least(1).item
    end
    it "assigns frequency" do
      freq = assigns(:freq)
      m2freq = freq.select{|f| f['medium'].to_i == media(:medium1).id}.first
      m2freq['ct'].should == 1
    end
    it "draws tag cloud" do
      response.should have_tag('.tagcloud')
    end
    it "tag cloud has items" do
      response.should have_tag('.clouditem')
    end
    it "tag cloud has a selected one" do
      response.should have_tag('.clouditem.tagmatch')
    end
    it "pieces are in order of art_piece updated_date" do
      assigns(:pieces).sort_by(&:updated_at).should == assigns(:pieces)
    end
    context " an id that doesn't exist " do
      before do
        get :show, :id => 0
      end
      it "should redirect" do
        response.should redirect_to medium_path Medium.first
      end
    end
  end
  describe "#edit" do
    before do
      get :edit, :id => media.first
    end
    it_should_behave_like 'not authorized'
    context "as an editor" do
    end
    context "as an admin" do
    end
  end
end
      
