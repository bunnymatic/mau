require 'test_helper'

class ArtPiecesHelperTest < ActionView::TestCase
  fixtures :art_pieces
  test "compute pagination" do
    pieces = []
    20.times { |x| pieces << x }
    
    # input args [ array of pieces, curpage, perpage ]
    # output format [ shows, nextpage, prevpage, curpage, lastpage ]
    # expectations is [ inputs, expected output ]
    
    # normal cases
    expectations = [ [[pieces, 2, 5], [[14, 13, 12, 11, 10], 3, 1, 2, 3]],
                     [[pieces, 4, 2], [[9,8], 5,3,4,9]],
                     [[pieces, 0, 20], [pieces.reverse, 0,0,0,0]],
                     [[pieces, 1, 20], [[], 0,0,1,0]],
                     [[pieces, 1, 7],[[13,12,11,10,9,8,7], 2, 0, 1, 2]],
                     [[pieces, 20,21],[nil, 0, 19, 20, 0]],
                     [[pieces, 20,20],[nil, 0, 19, 20, 0]],
                     [[pieces, 20,19],[nil, 1, 19, 20, 1]],
                     [[pieces, -1, 5], [[4,3,2,1,0], 1,0,0,3]],
                     [[pieces, 1, -10], nil],
                     [["whatever", 10, 20], [nil,0,9,10,0]]
                   ]
    expectations.each do |ins, outs|
      results = ArtPiecesHelper.compute_pagination(*ins)
      assert_equal(results, outs, "Wrong results with inputs %s" % [ins])
    end
    #error cases
    x = ArtPiecesHelper.compute_pagination(7, 10, 20)
    assert(!x)
    x = ArtPiecesHelper.compute_pagination(nil, 10, 20)
    assert(!x)
  end

  fixtures :art_pieces
  test "compute image size" do
    img = art_pieces(:h1024w2048)
    expectations = { 'small' => [ 200, 100 ],
                     's' => [200, 100],
                     'm' => [400, 200],
                     'med' => [400, 200],
                     'medium' => [400, 200],
                     'std' => [400, 200],
                     'standard' => [400,200],
                     'original' => [img.image_width, img.image_height],
                     'orig' => [img.image_width, img.image_height],
                     'thumb' => [100, 50],
      'thumbnail' => [100, 50] }
    expectations.each_pair do |sz,expect|
      rs = compute_actual_image_size(sz, img)
      assert_equal(rs, expect, "Failed to compute size for %s" % sz)
    end
  end
end

