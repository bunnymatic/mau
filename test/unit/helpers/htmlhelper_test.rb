require 'test_helper'
class HTMLHelperTest < ActionView::TestCase
  test "encode" do
    expectations = [['this that and <a>the other</a>', "this that and &lt;a&gt;the other&lt;/a&gt;"],
                    ["?&'\"", "?&amp;&apos;&quot;"],
                    ["\\", "\\"],
                    ["",""],
                    [nil, ""],
                    [[1,2,3], "123"],
                    ["nothing to change here", "nothing to change here"],
                    ["nothing to\nchange here", "nothing to\nchange here"]]
    expectations.each { 
      |inp, outp|  assert_equal(outp, HTMLHelper.encode(inp)) 
    }
  end

  test "query encode" do
    expectations = [[{ "arg1" => "val1", "arg2" => "val2"}, "?arg1=val1&arg2=val2"],
                    [{ "arg3" => "http://www.cnn.com?story=123&stuff=b",
                       "arg1" => "<>", 
                       "query" => "super man"}, "?arg3=http%3A%2F%2Fwww.cnn.com%3Fstory%3D123%26stuff%3Db&arg1=%3C%3E&query=super+man"],
                    [nil, "?"],
                    ["not a hash", "?"],
                    [-10, "?"],
                    [[1,2,3], "?"],
                   ]
    expectations.each { 
      |inp, outp|  assert_equal(outp, HTMLHelper.queryencode(inp)) 
    }
  end
end
