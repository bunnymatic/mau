module MobileHelper

  def render_as_mobile_list_item (content, opts)
    link = opts[:link] || '#'
    clz = opts[:xtra_class] || ''
    os_star = opts[:os_star]
    if os_star
      clz += " os-star"
      star_code = "<div class='os-star'></div>"
    end
    link += "/" unless (/\/$/.match(link) || /\?\w+/.match(link))
    a = content_tag('a', [star_code, content].join, {'data-transition' => :slide, href: link})
    content_tag('li', a, class: "mobile-menu #{clz}")
  end

end
