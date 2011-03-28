require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CatalogController do

  integrate_views

  fixtures :users, :studios, :artist_infos

  describe "#index" do
    before do
      ActiveRecord::Base.connection.execute("update artist_infos set open_studios_participation = '201104'")
      Artist.any_instance.stubs(:in_the_mission? => true)
      a = users(:jesseponce)
      ai = artist_infos(:jesseponce)
      a.artist_info = ai
      a.save
      s = studios(:s1890)
      a.studio = s
      a.save
      
      a = users(:artist1)
      ai = artist_infos(:artist1)
      a.artist_info = ai
      a.save
      s = studios(:blue)
      a.studio = s
      a.save
      
      b = users(:joeblogs)
      bi = artist_infos(:joeblogs)
      b.artist_info = bi
      b.studio_id = 0
      b.save
      
      c = users(:annafizyta)
      ci = artist_infos(:annafizyta)
      c.artist_info = ci
      c.studio_id = 0
      c.save

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
    it "has section for studios" do
      response.should have_tag('.section.studios')
    end
    it 'has section for artists' do
      response.should have_tag('.section.artists')
    end
    it 'has section for events' do
      response.should have_tag('.section.events')
    end
      
  end
end
