module MobileHelper

  def render_as_mobile_list_item (content, opts)
    link = opts[:link] || '#'
    clz = opts[:xtra_class] || ''
    
    return <<EOM
       <li class="mobile-menu #{clz}"><a data-transition="slide" rel="external" href="#{link}">#{content}</a></li>
EOM
  end

end
