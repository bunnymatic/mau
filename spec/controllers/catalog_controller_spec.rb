require 'spec_helper'

describe CatalogController do

  fixtures :users, :studios, :artist_infos

  describe "#index" do
    before do
      ActiveRecord::Base.connection.execute("update artist_infos set open_studios_participation = '201210'")
      Artist.any_instance.stub(:in_the_mission? => true)
      users(:jesseponce).update_attribute(:studio, studios(:s1890))
      users(:artist1).update_attribute(:studio, studios(:blue))

      get :index
    end
    it "has independent artists in a bin" do
      artists = assigns(:indy_artists)
      artists.should be_a Array
      artists.should have_at_least(1).artist
    end
    it "indy artists are sorted by last name" do
      artists = assigns(:indy_artists)
      artists.map(&:lastname).map(&:downcase).should be_monotonically_increasing
    end
    it "has group studio artists in a bin" do
      artists = assigns(:group_studio_artists)
      artists.should be_a Hash
      artists.should have_at_least(1).artist
    end
    it "assigns studio order in the correct order" do
      (assigns(:studio_order).map{|sid| Studio.find(sid)}.sort &Studio.sort_by_name).map(&:id).should eql assigns(:studio_order)
    end
    it "studio artists are sorted alpha by lastname" do
      assigns(:group_studio_artists).each do |s,artists|
        artists.map(&:lastname).map(&:downcase).should be_monotonically_increasing
      end
    end
  end

  describe '#social' do
    context 'format=html' do
      before do
        get :social
      end
      it { response.should_not be_success }
    end
    context 'format=mobile' do
      before do
        get :social, :format => :mobile
      end
      it { response.should redirect_to root_path }
    end
    context 'format=csv' do
      before do
        get :social, :format => :csv
      end
      it { response.should be_success }
      it {
        pending "test data in csv"
      }
    end

  end
end
