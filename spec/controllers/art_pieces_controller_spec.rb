require "spec_helper"

include AuthenticatedTestHelper

describe ArtPiecesController do

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

  describe "show" do
    before(:each) do
      get :show, :id => @artpieces.first.id
    end
    it "returns success" do
      response.should be_success
    end
    it "displays art piece" do
      response.should have_tag("#artpiece_title", @artpieces.first.title)
      response.should have_tag("#ap_title", @artpieces.first.title)
    end
    it "has no edit buttons" do
      response.should have_tag("div.edit-buttons", "")
    end
    context "when logged in as art piece owner" do
      before do
        login_as(@artist)
        get :show, :id => @artpieces.first.id
      end
      it "shows edit button" do
        response.should have_tag("div.edit-buttons span#artpiece_edit a", "edit")
      end
      it "shows delete button" do
        get :show, :id => @artpieces.first.id
        response.should have_tag(".edit-buttons #artpiece_del a", "delete")
      end
    end
  end
end
