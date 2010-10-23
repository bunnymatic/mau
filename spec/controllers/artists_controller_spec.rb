require 'spec_helper'


include AuthenticatedTestHelper

describe ArtistsController, 'arrangeart'  do

  fixtures :artists
  fixtures :art_pieces

  def save_artist_with_artpieces
    apids =[]
    a = artists(:artist1)
    a.save!
    ap = art_pieces(:artpiece1)
    ap.artist_id = a.id
    ap.save!
    apids << ap.id
    ap = art_pieces(:artpiece2)
    ap.artist_id = a.id
    ap.save!
    apids << ap.id
    ap = art_pieces(:artpiece3)
    ap.artist_id = a.id
    ap.save!
    apids << ap.id
    { :artist => a, :art_piece_ids => apids }
  end

  it 'should put representative as last uploaded piece' do
    r = save_artist_with_artpieces
    a = r[:artist]
    a = Artist.find_by_id(a.id)
    a.representative_piece.title.should == 'third'
  end

  it 'should return art_pieces in created time order' do
    r = save_artist_with_artpieces
    a = r[:artist]
    aps = a.art_pieces
    aps.count.should == 3
    aps[0].title.should == 'third'
    aps[1].title.should == 'second'
    aps[2].title.should == 'first'
  end

  it 'should return art_pieces in new order (2,1,3)' do
    r = save_artist_with_artpieces
    a = r[:artist]
    apids = r[:art_piece_ids]
    order1 = [ apids[1], apids[0], apids[2] ]
    
    login_as(a)

    # user should be logged in now
    post :setarrangement, { :neworder => order1.join(",") }
    response.code.should == "302"

    aid = a.id
    a = Artist.find(aid)
    aps = a.art_pieces
    aps.count.should == 3
    aps[0].title.should == 'second'
    aps[1].title.should == 'first'
    aps[2].title.should == 'third'
    aps[0].artist.representative_piece.id.should==aps[0].id

  end

  it 'should return art_pieces in new order (1,3,2)' do
    r = save_artist_with_artpieces
    a = r[:artist]
    apids = r[:art_piece_ids]
    order1 = [ apids[0], apids[2], apids[1] ]
    login_as(a)

    post :setarrangement, { :neworder => order1.join(",") }
    response.code.should == "302"

    aid = a.id
    a = Artist.find(aid)
    aps = a.art_pieces
    aps.count.should == 3
    aps[0].title.should == 'first'
    aps[1].title.should == 'third'
    aps[2].title.should == 'second'
    aps[0].artist.representative_piece.id.should==aps[0].id
  end
end
