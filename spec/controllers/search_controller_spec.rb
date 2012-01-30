require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe SearchController do

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :media
  fixtures :art_piece_tags
  fixtures :art_pieces_tags
  before do
    Rails.cache.stubs(:read).returns(nil)
  end
  describe "#index" do
    integrate_views
    describe "(with views)" do
      before do
        get :index, :query => "go fuck yourself.  this string ought to never match anything"
      end
      it_should_behave_like "not logged in"
    end
    
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
    [:annafizyta, :artist1].each do |artist|
      %w[ firstname lastname login fullname].each do |term|
        context "for #{artist} by #{term}" do
          before do
            @artist = users(artist)
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

      %w[ firstname lastname fullname].each do |term|
        context "finds artists even if there are extra spaces in the query using #{artist}.#{term}" do
          before do
            @artist = users(artist)
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

      %w[firstname lastname fullname].each do |term|
        context "capitalization of search term for #{artist}.#{term}" do
          before do
            @artist = users(artist)
            get :index, :query => @artist.send(term).capitalize
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
      %w[firstname lastname fullname].each do |term|
        context "uppercase of search term for #{artist}.#{term}" do
          before do
            @artist = users(artist)
            get :index, :query => @artist.send(term).upcase
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
end
