require File.dirname(__FILE__) + "/../spec_helper"

describe ArtistsHelper do
  fixtures :users, :studios, :artist_infos
  describe "#get_map_info" do
    before do
      a = users(:joeblogs)
      a.studio = studios(:s1890)
      a.artist_info = artist_infos(:joeblogs)
      a.save!

      a = users(:jesseponce)
      a.artist_info = artist_infos(:jesseponce)
      a.save!
    end
    describe "for artist with group studio" do
      before do
        @info = get_map_info(users(:joeblogs))
      end
      it "includes the artists name" do
        @info.should match /#{users(:joeblogs).name}/
      end
      it "includes studio's address" do
        @info.should match /#{studios(:s1890).street}/
      end      
    end
    describe "for artist without group studio" do
      before do
        @info = get_map_info(users(:jesseponce))
      end
      it "includes the artists name" do
        @info.should match /#{users(:jesseponce).name}/
      end
      it "includes artists' address" do
        @info.should match /#{users(:jesseponce).street}/
      end
    end
  end
end
