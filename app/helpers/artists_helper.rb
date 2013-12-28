require 'htmlhelper'

module ArtistsHelper
  include MauUrlHelpers
  #
  # Link to user's page ('artists/1')
  #
  # By default, their login is used as link text and link title (tooltip)
  #
  # Takes options
  # * :content_text => 'Content text in place of artist.login', escaped with
  #   the standard h() function.
  # * :content_method => :artist_instance_method_to_call_for_content_text
  # * :title_method => :artist_instance_method_to_call_for_title_attribute
  # * as well as link_to()'s standard options
  #
  # Examples:
  #   link_to_artist @artist
  #   # => <a href="/artists/3" title="barmy">barmy</a>
  #
  #   # if you've added a .name attribute:
  #  content_tag :span, :class => :vcard do
  #    (link_to_artist artist, :class => 'fn n', :title_method => :login, :content_method => :name) +
  #          ': ' + (content_tag :span, artist.email, :class => 'email')
  #   end
  #   # => <span class="vcard"><a href="/artists/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a>: <span class="email">barmy@blandings.com</span></span>
  #
  #   link_to_artist @artist, :content_text => 'Your user page'
  #   # => <a href="/artists/3" title="barmy" class="nickname">Your user page</a>
  #
  # def link_to_artist(artist, options={})
  #   raise "Invalid artist" unless artist
  #   options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
  #   content_text      = options.delete(:content_text)
  #   content_text    ||= artist.send(options.delete(:content_method))
  #   options[:title] ||= artist.send(options.delete(:title_method))
  #   link_to h(content_text), artist_path(artist), options
  # end

  # #
  # # Link to login page using remote ip address as link content
  # #
  # # The :title (and thus, tooltip) is set to the IP address
  # #
  # # Examples:
  # #   link_to_login_with_IP
  # #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  # #
  # #   link_to_login_with_IP :content_text => 'not signed in'
  # #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  # #
  # def link_to_login_with_IP content_text=nil, options={}
  #   ip_addr           = request.remote_ip
  #   content_text    ||= ip_addr
  #   options.reverse_merge! :title => ip_addr
  #   if tag = options.delete(:tag)
  #     content_tag tag, h(content_text), options
  #   else
  #     link_to h(content_text), login_path, options
  #   end
  # end

  # #
  # # Link to the current user's page (using link_to_artist) or to the login page
  # # (using link_to_login_with_IP).
  # #
  # def link_to_current_artist(options={})
  #   if current_artist
  #     link_to_artist current_artist, options
  #   else
  #     content_text = options.delete(:content_text) || 'not signed in'
  #     # kill ignored options from link_to_artist
  #     [:content_method, :title_method].each{|opt| options.delete(opt)}
  #     link_to_login_with_IP content_text, options
  #   end
  # end

  def has_links(artist)
    Artist::KEYED_LINKS.each do |kk, disp|
      if artist[kk] and !artist[kk].empty?
        return true
      end
    end
    return false
  end

  def bio_html(bio)
    biostr = ""
    bio.split("\n").each do |line|
      biostr += (HTMLHelper.encode(line) + "<br/>")
    end
    biostr.html_safe
  end

  # get info for google map info window as html
  # if you have lat lon, include it for directions link
  def get_map_info(artist)
    html = '<style type="text/css">._mau1 { color: #222222; font-size: x-small; } _mau1 a{ color: #ff2222; }</style><div class="_mau1">'
    ap = artist.representative_piece
    aname = artist.get_name(true)
    img = ''
    # tried to add title to these links, but it seems google maps
    # is too smart for that.
    if (ap && ap.is_a?(ArtPiece))
      img = "<a class='lkdark' href='%s'><img src='%s'/></a>" % [ artist_path(artist), ap.get_path('thumb') ]
      html += '<div class="_mau1" style="float:right;">%s</div>' % img
    end
    address = artist.address_hash
    name = "<a class='lkdark' href='%s'>%s</a>" % [ artist_path(artist), aname ]
    street = address[:parsed][:street]
    if artist.studio_id.nil? or artist.studio_id == 0
      html += "%s<div>%s</div>" % [ name, street ]
    else
      html += "%s<div>%s</div><div>%s</div>" % [name, artist.studio.name, street]
    end
    html += '<div style="clear"></div>'
    # if
    #   lnk = '<a class="lkdark" href="http://maps.google.com/maps?saddr=&daddr=%s" target ="_blank">Get directions</a>' % HTMLHelper.encode(artist.full_address)
    #   html += '<div style="margin-top:8px">%s</div>' % lnk
    # end

    html += "</div>"
  end

  def for_mobile_list(artist)
    artist.get_name true
  end

end
