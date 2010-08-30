require 'test_helper'
require 'action_view/test_case'

class CookiesHelperTest < ActionView::TestCase
  test "encode_cookie" do 
    v = encode_cookie( {:blah => "blurp" })
    assert_equal(v,"eyJibGFoIjoiYmx1cnAifQ==\n")
  end

  test "decode_cookie" do 
    v = decode_cookie( "eyJibGFoIjoiYmx1cnAifQ==\n" )
    expected = {"blah" => "blurp" }
    assert( v["blah"] )
    assert_equal( v["blah"], expected["blah"] )
  end

  test "full circle" do
    a = { "arr" => [ 1, 2, 3, "string" ],
          "str" => "string",
      "pi" => 3.1415 }
    b = decode_cookie(encode_cookie(a))
    assert(b.keys() == a.keys())
    b.keys().each() do |k|
      assert_equal(b[k],a[k])
    end

  end
  test "bad_decode1" do
    v = decode_cookie("bogus cookie data")
    assert_equal(v,{})
  end

  test "bad_decode2" do
    v = decode_cookie({ :blurp => "blah" })
    assert_equal(v,{})
  end

  test "bad_encode1" do
    v = encode_cookie("stuff")
    assert_equal(v,"")
  end
  test "bad_encode2" do
    v = encode_cookie(0.5)
    assert_equal(v,"")
  end
end
