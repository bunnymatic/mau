require 'htmlentities'

module HtmlHelper
  # adds first and last to the list
  def print_html_list(clazz, html_arr)
    nel = html_arr.count
    html_arr.map.with_index do |el, idx|
      cls = clazz
      if idx.zero?
        cls += ' first'
      elsif idx == (nel - 1)
        cls += ' last'
      end
      "<li class='#{cls}'>#{el}</li>"
    end.join
  end
end
