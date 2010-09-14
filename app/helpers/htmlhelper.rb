require 'htmlentities'
module HTMLHelper
  @@HTMLcoder = HTMLEntities.new
  
  def self.encode(s)
    @@HTMLcoder.encode(s)
  end
  
  def self.queryencode(d)
    s = []
    begin
      d.each_pair do |k,v| 
        if !v.nil?
          s << "%s=%s" % [k,CGI::escape(v.to_s)]
        end
      end
      "?"+s.join("&")
    rescue Exception => ex
      RAILS_DEFAULT_LOGGER.warn("Failed to encode urlencode %s" % d)
      RAILS_DEFAULT_LOGGER.warn(ex)
      return "?"
    end
  end
end

