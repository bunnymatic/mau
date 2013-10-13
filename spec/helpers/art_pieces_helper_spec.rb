require 'spec_helper'

describe ArtPiecesHelper do

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
end
