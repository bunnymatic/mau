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
    aps = %w(hot not h1024w2048 negative_size artpiece1 artpiece2 artpiece3).map{|k| art_pieces(k)}

    meds = %w(medium1 medium2 medium3).map{|k| media(k)}

    artists = %w(quentin artist1 joeblogs).map{|k| users(k)}

    aps.each_with_index do |ap, idx|
      medium = meds[idx % meds.size]
      artist = artists[(idx + 2) % artists.size]
      ap.update_attributes(:artist => artist, :medium => medium)
    end
  end

  context "show" do
    before do
      get :show, :id => Medium.first.id, :format => :mobile
    end
    it_should_behave_like 'a regular mobile page'
    it_should_behave_like "non-welcome mobile page"
    it "returns success" do
      expect(response).to be_success
    end
    it "assigns artists" do
      assigns(:artists).should have_at_least(1).artist
    end
    it "assigns frequency" do
      assigns(:frequency).should have_at_least(1).item
    end
    it "assigns frequency correctly" do
      freq = assigns(:frequency)
      m2freq = freq.select{|f| f['medium'].to_i == media(:medium1).id}.first
      m2freq['ct'].should eql 1.0
    end
    it 'artists list should not include duplicates' do
      assigns(:artists).uniq.count.should eql assigns(:artists).count
    end
  end
end
