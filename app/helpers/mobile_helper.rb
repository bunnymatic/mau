module MobileHelper

  def render_as_mobile_list_item (content, opts)
    link = opts[:link] || '#'
    clz = opts[:xtra_class] || ''
    os_star = opts[:os_star]
    if os_star
      clz += " os-star"
      star_code = "<div class='os-star'></div>"
    end
    return <<EOM
       <li class="mobile-menu #{clz}"><a data-transition="slide" rel="external" href="#{link}">#{star_code}#{content}</a></li>
EOM
  end

end
