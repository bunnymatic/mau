require 'htmlentities'

module HtmlHelper

  def html_encode(s)
    coder.encode(s, :named, :hexadecimal)
  end

  def html_queryencode(d)
    "?" + d.map{|k,v| "%s=%s" % [k,CGI::escape(v.to_s)] if v}.compact.uniq.join("&")
  end

  # adds first and last to the list
  def print_html_list(clazz, html_arr)
    nel = html_arr.count
    html_arr.map.with_index do |el, idx|
      cls = clazz
      if idx == 0
        cls += ' first'
      elsif idx == (nel - 1)
        cls += ' last'
      end
      "<li class='#{cls}'>" + el + "</li>"
    end.join('')
  end

  def coder
    @coder ||= HTMLEntities.new
  end

end

