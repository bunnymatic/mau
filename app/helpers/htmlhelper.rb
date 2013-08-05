require 'htmlentities'
module HTMLHelper
  @@HTMLcoder = HTMLEntities.new
  
  def self.encode(s)
    @@HTMLcoder.encode(s, :hexadecimal)
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

  # adds first and last to the list
  def self.print_list(clazz, html_arr)
    nel = html_arr.count
    lst = []
    html_arr.each_with_index do |el, idx|
      cls = clazz
      if idx == 0
        cls += ' first'
      elsif idx == (nel - 1)
        cls += ' last'
      end
      lst << "<li class='#{cls}'>" + el + "</li>"
    end
    lst.join("").html_safe
  end
end

