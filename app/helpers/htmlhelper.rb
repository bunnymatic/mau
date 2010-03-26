require 'htmlentities'
module HTMLHelper
  @@HTMLcoder = HTMLEntities.new
  
  def self.encode(s)
    @@HTMLcoder.encode(s)
  end
  
  def self.queryencode(d)
    s = []
    d.each do |k,v| 
      if !v.nil?
        s << "%s=%s" % [k,v]
      end
    end
    "?"+s.join("&")
  end
      
end

