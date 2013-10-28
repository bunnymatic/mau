require 'spec_helper'

describe MediaController do

  render_views

  fixtures :media
  fixtures :art_pieces
  fixtures :users, :roles, :roles_users

  before do
    # do mobile
    Artist.any_instance.stub(:os_participation => {'201104' => true})

    request.stub(:user_agent => IPHONE_USER_AGENT)

    Rails.cache.stub(:read => nil)

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

  context "show" do
    before do
      get :show, :id => Medium.first.id
    end
    it_should_behave_like 'a regular mobile page'
    it_should_behave_like "non-welcome mobile page"
    it "returns success" do
      response.should be_success
    end
    it "assigns artists" do
      assigns(:artists).should have_at_least(1).artist
    end
    it "assigns frequency" do
      assigns(:freq).should have_at_least(1).item
    end
    it "assigns frequency correctly" do
      freq = assigns(:freq)
      m2freq = freq.select{|f| f['medium'].to_i == media(:medium1).id}.first
      m2freq['ct'].should eql 1.0
    end
    context "an id that doesn't exist" do
      before do
        get :show, :id => 0
      end
      it "should redirect" do
        response.should redirect_to medium_path Medium.first
      end
    end
    it 'artists list should not include duplicates' do
      assigns(:artists).uniq.count.should eql assigns(:artists).count
    end
  end
end
