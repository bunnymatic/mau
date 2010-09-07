require 'htmlentities'
module HTMLHelper
  @@HTMLcoder = HTMLEntities.new
  
  def self.encode(s)
    @@HTMLcoder.encode(s)
  end
  
  def self.queryencode(d)
    s = []
    begin
      d.each do |k,v| 
        if !v.nil?
          s << "%s=%s" % [k,CGI::escape(v)]
        end
      end
      "?"+s.join("&")
    rescue
      return "?"
    end
  end
end

