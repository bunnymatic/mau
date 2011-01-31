module WizardsHelper

  def draw_chooser_item piece, options=nil
    options ||= {}
    xclass = options[:class]
    checkbox = (options.has_key? :checkboxes) ? options[:checkboxes] : true
    img = piece.get_path 'small'
    del_btn = ''

    s = '' 
    if img
      s = "<li><div class='thumb #{xclass}'><img src='#{img}'></div><div class='name'>"
      if checkbox
        s += check_box( 'art', piece.id, options = { :class => "checker" }, checked_value = "1", unchecked_value = "0")
      else
        s += "<input type='hidden' name='art[#{piece.id}]' value='#{piece.id}'/>"
      end
      s += "<span>#{piece.get_name(true)}</span></div><div class='clear'></div></li>"
    end
    s
  end

end
