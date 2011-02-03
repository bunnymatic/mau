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
    m2 = media(:medium2)

    a = users(:annafizyta)
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
    a.artist_info = artist_infos(:artist1)
    a.save

    @artist = a
    @artpieces = art_pieces

    a = users(:jesseponce)
    a.art_pieces << art_pieces(:hot)
    a.save
    @jesse = a
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
      
    [:firstname, :lastname, :login, :fullname].each do |term|
      context "for annafizyta by #{term}" do
        before do
          get :index, :query => @artist.send(term)
        end
        it "returns some results" do
          assigns(:pieces).should have_at_least(1).art_piece
        end
        it "artist 1 owns all the art in those results" do
          assigns(:pieces).each do |ap|
            ap.artist.id.should == @artist.id
          end
        end
      end
    end

    [:firstname, :lastname, :login, :fullname].each do |term|
      context "for jesse ponce (who has no address) by #{term}" do
        before do
          get :index, :query => @artist.send(term)
        end
        it "returns some results" do
          assigns(:pieces).should have_at_least(1).art_piece
        end
        it "artist 1 owns all the art in those results" do
          assigns(:pieces).each do |ap|
            ap.artist.id.should == @artist.id
          end
        end
      end
    end

    [:firstname, :lastname, :login, :fullname].each do |term|
      context "finds artists even if there are extra spaces in the query using artists' #{term}" do
        before do
          get :index, :query => @artist.send(term) + " "
        end
        it "returns some results" do
          assigns(:pieces).should have_at_least(1).art_piece
        end
        it "artist 1 owns all the art in those results" do
          assigns(:pieces).each do |ap|
            ap.artist.id.should == @artist.id
          end
        end
      end
    end

  end
end
