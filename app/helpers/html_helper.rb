require 'htmlentities'
module HtmlHelper
  @@HTMLcoder = HTMLEntities.new
  
  def self.encode(s)
    @@HTMLcoder.encode(s)
  end
end
