# helpers for strings
module StringHelpers
  def trim(str, len)
    if len < (str.length+3)
      str[0..len] + "..."
    else
      str
    end
  end
  
  def strip_html_tags(str)
    str.gsub(/<\/?[^>]*>/, "")
  end
  
end

  
