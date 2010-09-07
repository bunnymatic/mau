require 'test_helper'

class TagsHelperTest < ActionView::TestCase
  fixtures :tags
  test "tags to string" do
    ts = []
    ts << tags(:one)
    ts << tags(:two)
    ts << tags(:with_spaces)
    s = TagsHelper.tags_to_s(ts)
    assert_equal(s, 'Tag1, Tag2, this is the tag')
  end
  
  test "tags from string" do
    expected_names = [ "one", "two", "three four", "seven" ]
    tagstr = expected_names.join(',')
    ts = TagsHelper.tags_from_s(tagstr)
    expected_names.each do |n|
      found = false
      ts.each do |t|
        if t.name == n
          found = true
          break
        end
      end
      assert(found, "Failed to find tag [%s]" % n)
    end
  end
  
  test "fontsize freq" do
    [ [0.1, ['9px','4px']], [0.4,['16px','4px']], [0.8,['23px','4px']], [1,['24px','4px']] ].each do |f,ef|
      r = TagsHelper.fontsize_from_frequency(f)
      assert_equal(r, ef)
        
    end
  end

end
