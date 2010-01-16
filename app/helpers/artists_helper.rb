require 'htmlentities'

module ArtistsHelper
  
  #
  # Use this to wrap view elements that the user can't access.
  # !! Note: this is an *interface*, not *security* feature !!
  # You need to do all access control at the controller level.
  #
  # Example:
  # <%= if_authorized?(:index,   User)  do link_to('List all users', users_path) end %> |
  # <%= if_authorized?(:edit,    @user) do link_to('Edit this user', edit_user_path) end %> |
  # <%= if_authorized?(:destroy, @user) do link_to 'Destroy', @user, :confirm => 'Are you sure?', :method => :delete end %> 
  #
  #
  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

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
  def link_to_artist(artist, options={})
    raise "Invalid artist" unless artist
    options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
    content_text      = options.delete(:content_text)
    content_text    ||= artist.send(options.delete(:content_method))
    options[:title] ||= artist.send(options.delete(:title_method))
    link_to h(content_text), artist_path(artist), options
  end

  #
  # Link to login page using remote ip address as link content
  #
  # The :title (and thus, tooltip) is set to the IP address 
  #
  # Examples:
  #   link_to_login_with_IP
  #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_login_with_IP :content_text => 'not signed in'
  #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  #
  def link_to_login_with_IP content_text=nil, options={}
    ip_addr           = request.remote_ip
    content_text    ||= ip_addr
    options.reverse_merge! :title => ip_addr
    if tag = options.delete(:tag)
      content_tag tag, h(content_text), options
    else
      link_to h(content_text), login_path, options
    end
  end

  #
  # Link to the current user's page (using link_to_artist) or to the login page
  # (using link_to_login_with_IP).
  #
  def link_to_current_artist(options={})
    if current_artist
      link_to_artist current_artist, options
    else
      content_text = options.delete(:content_text) || 'not signed in'
      # kill ignored options from link_to_artist
      [:content_method, :title_method].each{|opt| options.delete(opt)} 
      link_to_login_with_IP content_text, options
    end
  end


  def add_http(lnk)
    if lnk && !lnk.empty? && lnk.index('http') != 0
      lnk = 'http://' + lnk
    end
    lnk
  end

  def keyed_links
    [ [:url, 'Website'],
	       [:facebook, 'Facebook'],
	       [:flickr, 'Flickr'],
	       [:twitter, 'Twitter'],
	       [:blog, 'Blog'],
	       [:myspace, 'MySpace']]
  end

  def has_links(artist)
    keyed_links.each do |kk, disp|
      if artist[kk] and !artist[kk].empty?
        return true
      end
    end
    return false
  end

  def bio_html(bio)
    coder = HTMLEntities.new
    biostr = ""
    bio.split("\n").each do |line|
      biostr += (coder.encode(line) + "<br/>")
    end
    biostr
  end

  def email_link(artist)
    if !artist.email.empty?
      (uname, domain) = artist.email.split('@')
      '<a href="#" onclick="MAU.mailer(\'%s\',\'%s\');">%s at %s</a>' % [uname, domain, uname, domain]
    else
      ''
    end
  end
end
