require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe SearchController do

  integrate_views

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :media

  before(:each) do 
    # stash an artist and art pieces
    art_pieces =[]
    m1 = media(:medium1)
    m1.save!
    m2 = media(:medium2)
    m2.save!

    a = users(:artist1)
    a.save!
    ap = art_pieces(:artpiece1)
    ap.artist_id = a.id
    ap.medium_id = m2.id
    ap.save!
    art_pieces << ap
    ap = art_pieces(:artpiece2)
    ap.artist_id = a.id
    ap.medium_id = m1.id
    ap.save!
    art_pieces << ap
    ap = art_pieces(:artpiece3)
    ap.artist_id = a.id
    ap.medium_id = nil
    ap.save!
    art_pieces << ap
    info = artist_infos(:artist1)
    info.artist_id = a.id
    info.save!
    
    a.artist_info = info
    @artist = a
    @artpieces = art_pieces
  end

  describe "search" do
    before do
      get :index, :query => "go fuck yourself.  this string ought to never match anything"
    end

    it_should_behave_like "not logged in"
    
    context "for something we don't have" do
      it "returns nothing" do
        get :index, :query => "go fuck yourself.  this string ought to never match anything"
        response.should_not have_tag('.search-thumb-info')
      end
      it "show message indicating that nothing matched" do
        get :index, :query => "go fuck yourself.  this string ought to never match anything"
        response.should include_text("go fuck yourself")
        response.should include_text("couldn't find anything that matched")
      end
    end
      
    context "for artist1 by login" do
      it "returns artist1" do
        get :index, :query => @artist.login
        response.should have_tag('.search-thumb-info')
      end
    end
    context "for artist1 by lastname" do
      it "returns artist1" do
        get :index, :query => @artist.lastname
        response.should have_tag('.search-thumb-info')
      end
    end
  end

  
end
