require 'spec_helper'

include AuthenticatedTestHelper

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
    context 'for valid medium' do
      render_views
      before do
        get :show, :id => Medium.first.id
      end
      it_should_behave_like 'two column layout'
      it_should_behave_like "not logged in"
      it "assigns results_mode p" do
        assigns(:results_mode).should eql 'p'
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
        assigns(:pieces).map(&:updated_at).should be_monotonically_increasing
      end
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
    context 'as unauthorized' do
      before do
        get :edit, :id => Medium.first
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      before do
        login_as :admin
        get :edit, :id => Medium.first
      end
      it { response.should be_success }
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
        login_as :admin
        get :new
      end
      it { response.should be_success }
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
        login_as :admin
      end
      it { expect{ post :create, :medium => {:name => 'blah'} }.to change(Medium, :count).by(1) }
      it 'redirects back to the new medium show page' do
        post :create, :medium => {:name => 'blah'}
        response.should redirect_to medium_path(Medium.where(:name => 'blah').first)
      end
      it 'renders new on error' do
        post :create, :medium => {:name => nil}
        response.should render_template 'new'
      end
    end
  end

  describe "#update" do
    context 'as unauthorized' do
      before do
        post :update
      end
      it_should_behave_like 'not authorized'
    end
    context "as an admin" do
      let(:medium) { Medium.first }
      before do
        login_as :admin
      end
      it 'redirects back to the new medium show page' do
        post :update, :id => medium.id, :medium => {:name => 'brand spankin new'}
        response.should redirect_to medium_path(medium)
      end
      it 'updates the medium' do
        post :update, :id => medium.id, :medium => {:name => 'brand spankin'}
        medium.reload.name.should eql 'brand spankin'
      end
      it 'renders new on error' do
        post :update, :id => medium.id, :medium => {:name => nil}
        response.should render_template 'edit'
      end
    end
  end

end
