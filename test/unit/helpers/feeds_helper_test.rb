require 'test_helper'
require 'action_view/test_case'

class FeedsHelperTest < ActionView::TestCase

  def variants(base)
    r = []
    ['www','http://','https://','http://www','http://news', 'blurbish'].each { |b| r << "%s.%s" % [b, base] }
    ['?whatever','/other_crap?stuff', '?twitter_feed&type=rss'].each { |b| r<<"%s%s" % [base, b] }
    r
  end

  test "get_twitter_icon" do
    variants('twitter.com').each do |url|
      ico = FeedsHelper.get_icon_class(url)
      assert_equal(ico,"twitter")
    end
  end

  test "get_blogger_icon" do
    variants('blogger.com').each do |url|
      ico = FeedsHelper.get_icon_class(url)
      assert_equal(ico,"blogger")
    end
    variants('blogspot.com').each do |url|
      ico = FeedsHelper.get_icon_class(url)
      assert_equal(ico,"blogger")
    end
  end

  test "get_flickr_icon" do
    variants('flickr.com').each do |url|
      ico = FeedsHelper.get_icon_class(url)
      assert_equal(ico,"flickr")
    end
  end

  test "get_fb_icon" do
    variants('facebook.com').each do |url|
      ico = FeedsHelper.get_icon_class(url)
      assert_equal(ico,"facebook")
    end
  end

  test "get_devart_icon" do
    variants('deviantart.com').each do |url|
      ico = FeedsHelper.get_icon_class(url)
      assert_equal(ico,"deviantart")
    end
  end

  test "get_wp_icon" do
    variants('wordpress.com').each do |url|
      ico = FeedsHelper.get_icon_class(url)
      assert_equal(ico,"wordpress")
    end
  end

  test "get_lj_icon" do
    variants('livejournal.com').each do |url|
      ico = FeedsHelper.get_icon_class(url)
      assert_equal(ico,"livejournal")
    end
  end

  test "get_default_icon" do
    ico = FeedsHelper.get_icon_class('')
    assert_equal(ico, 'rss')
    ico = FeedsHelper.get_icon_class('www.ebay.com')
    assert_equal(ico, 'rss')
    ico = FeedsHelper.get_icon_class('www.com/twitter')
    assert_equal(ico, 'rss')
    ico = FeedsHelper.get_icon_class('www.rss.com/twitter')
    assert_equal(ico, 'rss')
  end

  test "test truncate" do
    inp = 'this sentence is too long'
    t = FeedsHelper.trunc(inp, 20, true)
    n = t.length
    assert_equal(n, 20)
    assert_equal(t[0..16], inp[0..16])
    assert_equal(t[n-3..n], "...")

    t = FeedsHelper.trunc(inp, 20, false)
    n = t.length
    assert_equal(n, 20)
    assert_equal(t, inp[0..19])
    assert_not_equal(t[n-3..n], "...")

    inp = 'this sentence is just right'
    t = FeedsHelper.trunc(inp, 40, true)
    n = t.length
    assert_equal(inp, t)

    t = FeedsHelper.trunc(inp, 40, false)
    n = t.length
    assert_equal(inp, t)

    inp = 'what does it take to make a sentence that is too long for this thing to handle.  well it has to be at least 100 characters long so make it long.'
    t1 = FeedsHelper.trunc(inp, 100, ellipsis=true)
    t2 = FeedsHelper.trunc(inp)
    n = t1.length
    assert_equal(n, 100)
    assert_equal(t1[0..94], inp[0..94])
    assert_equal(t1[n-3..n], "...")
    assert_equal(t1,t2)

  end

end
