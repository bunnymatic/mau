require 'spec_helper'

describe ArtPiecesHelper do

  fixtures :art_pieces, :users, :studios, :media

  describe 'compute_pagination' do
    it 'works when there are fewer images than the page size' do
      showing, nextpage, prevpage, curpage, lastpage = ArtPiecesHelper.compute_pagination(['a'], 0, 10)
      showing.should eql ['a']
      nextpage.should eql 0
      prevpage.should eql 0
      curpage.should eql 0
      lastpage.should eql 0
    end
    it 'works when there are more images than the page size on the first page' do
      showing, nextpage, prevpage, curpage, lastpage = ArtPiecesHelper.compute_pagination(['a', 'b', 'c'], 1, 2)
      showing.should eql ['c']
      nextpage.should eql 1
      prevpage.should eql 0
      curpage.should eql 1
      lastpage.should eql 1
    end
    it 'works when there are more images than the page size on a middle page' do
      showing, nextpage, prevpage, curpage, lastpage = ArtPiecesHelper.compute_pagination(10.times.map(&:to_s), 2, 2)
      showing.should eql ['5','4']
      nextpage.should eql 3
      prevpage.should eql 1
      curpage.should eql 2
      lastpage.should eql 4
    end
  end

  describe 'fb_share_link' do
    let(:art) { art_pieces(:hot) }
    it 'builds the facebook share link as expected' do
      fb = ArtPiecesHelper.fb_share_link(art)
      fb.should match %r|^http://www.facebook.com/sharer.php?|
      fb.should include art.get_share_link(true)
      fb.should include "&t=#{CGI::escape("Check out #{art.artist.get_name()} ")}"
    end
  end

  describe 'tw_share_link' do
    let(:art) { art_pieces(:hot) }
    it 'builds the twitter share link as expected' do
      tw = ArtPiecesHelper.tw_share_link(art)
      tw.should match %r|^http://twitter.com/home|
      tw.should include art.get_share_link(true)
      tw.should include CGI.escape('@sfmau #missionartistsunited')
    end
  end

end
