require 'spec_helper'

describe CatalogController do

  fixtures :users, :studios, :artist_infos, :roles_users

  describe "#index" do
    before do
      ActiveRecord::Base.connection.execute("update artist_infos set open_studios_participation = '201210'")
      Artist.any_instance.stubs(:in_the_mission? => true)
      a = users(:jesseponce)
      s = studios(:s1890)
      a.studio = s
      a.save
      
      a = users(:artist1)
      s = studios(:blue)
      a.studio = s
      a.save
      
      get :index
    end
    it "has independent artists in a bin" do
      artists = assigns(:indy_artists)
      artists.should be_a Array
      artists.should have_at_least(1).artist
    end
    it "indy artists are sorted by last name" do
      artists = assigns(:indy_artists)
      (artists.sort &Artist.sort_by_lastname).should == artists
    end
    it "has group studio artists in a bin" do
      artists = assigns(:group_studio_artists)
      artists.should be_a Hash
      artists.should have_at_least(1).artist
    end
    it "assigns studio order in the correct order" do
      (assigns(:studio_order).map{|sid| Studio.find(sid)}.sort &Studio.sort_by_name).map(&:id).should == assigns(:studio_order)
    end
    it "studio artists are sorted alpha by lastname" do
      pending "we need better test data for this to fail"
      assigns(:group_studio_artists).values.each do |artists|
        (artists.sort &Artist.sort_by_lastname).should == artists
      end
    end
  end
end
