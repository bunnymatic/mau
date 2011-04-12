class AdminController < ApplicationController
  before_filter :admin_required
  layout 'mau-admin'
  def index
    render :text => "Nothing to see here.  Please move along."
  end

  def admin_emails
    @artists = Artist.find(:all, :conditions => ['state="active"'])
  end

  def emaillist
    artists = []
    arg = params[:listname]
    case arg
    when 'fans'
      @title = "Fans"
      fans = Users.find(:all, :conditions => "type <> 'Artist'")
    when 'spring2011'
      @title = "Spring 2011 OS Set"
      artists = Artist.active.open_studios_participants('201104')
    when 'activated'
      @title = "All Activated Artsts"
      artists = Artist.active.all
    when 'accounts'
      @title = "All Artist Accounts - active, suspended, pending etc *ALL*"
      artists = Artist.all
    when 'pending'
      @title = "Not yet activated artists"
      artists = Artist.find(:all, :conditions => [ "state='pending'" ])
    when 'noprofile'
      @title = "Artists who haven't submitted a profile picture"
      artists = Artist.active.find(:all, :conditions => [ "profile_image is null" ])
    when 'noimages'
      @title = "Artists who have not uploaded any images"
      sql = ActiveRecord::Base.connection()
      query = "select id from users where state='active' and id not in (select distinct artist_id from art_pieces);" 
      cur = sql.execute query
      aids = []
      cur.each_hash do |h|
        aids << h["id"]
      end
      print aids
      artists = Artist.find(:all, :conditions => { :id => aids })
    else
      @emails = []
      @msg = "What list did you want?"
      @title = "All Activated Artsts"
      artists = Artist.find(:all, :conditions => [ "state='active'" ])
    end
    @emails = []
    artists.each do |a|
      entry = { :id => a.id, :name => a.get_name, :email => a.email }
      @emails << entry
    end

  end

  def stats
    activated = Artist.active.count
    accounts = User.count
    fans = User.count(:conditions => "type <> 'Artist'")
    active_fans = User.active.count(:conditions => "type <>'Artist'")
    artists = accounts - fans
    artpieces = ArtPiece.count
    introuble = Artist.count(:conditions => "state='pending'")
    noprofile = Artist.active.count(:conditions => "profile_image is not null")
    octos = ArtistInfo.count(:conditions => "osoct2010 = 1")
    spring2011 = Artist.active.open_studios_participants('201104').count
    sql = ActiveRecord::Base.connection()
    query = "select count(*) ct from users where state='active' and id not in (select distinct artist_id from art_pieces);"

    noimages = []
    cur = sql.execute query
    cur.each_hash do |h|
      noimages << h['ct']
    end

    sql = ActiveRecord::Base.connection()
    query = "select favoritable_type tp, count(*) ct from favorites group by favoritable_type"

    favorited = {}
    cur = sql.execute query
    cur.each_hash do |h|
      favorited[h['tp']] = h['ct']
    end

    sql = ActiveRecord::Base.connection()
    query = "select count(distinct user_id) ct from favorites"

    users_using_favorites = []
    cur = sql.execute query
    cur.each_hash do |h|
      users_using_favorites << h['ct']
    end
    
    accts = {
      :accounts => { :name => "Total Accounts", :data => accounts },
      :fans => { :name => "Fans", :data => fans },
      :active_fans => { :name => 'Active Fans', :data => active_fans, :noemail => true },
      :artists => { :name => "Artists", :data => artists },
    }
    
    favinfo = {
      :favorited_artists => { :name => "Num times artist has been favorited", :data => favorited['Artist'], :noemail => true },
      :favorited_art_pieces => { :name => "Num times art pieces has been favorited", :data => favorited['ArtPiece'],  :noemail => true},
      :users_using_favorites => { :name => "Users using favorites", :data => users_using_favorites, :noemail => true }
    }

    d = {
      :activated => { :name => "Activated Artists", :data => activated },
      :pending => { :name => "Pending (not yet activated)", :data => introuble },
      :noprofile => { :name => "No Profile Image", :data => noprofile },
      :noimages => { :name => "No Uploaded Art", :data => noimages },
      :spring2011 => { :name => "Spring 2011 OS Set", :data => spring2011 },
    }

    @artpieces = artpieces
    @stats = { :accounts => accts,
      :artists => d,
      :favorites => favinfo }
    
  end

  def artists_per_day
    sql = ActiveRecord::Base.connection()
    @tbl = []
    cur = sql.execute "select count(*) ct,date(activated_at) d from users group by d order by d desc;"
    ctr = 0
    cur.each_hash do |h|
      @tbl << [h['ct'],h['d']]
    end
    @numrows = @tbl[-1][0].to_i
    @tbl.delete_at(-1)
    
    # format table into chunks of 7 days
    numperchunk = 11
    @chunks = []
    ctr = 1
    chunk = nil
    if @tbl.count < numperchunk
      @chunks = @tbl
    else
      @tbl.each do |c, d|
        if ctr == 1
          chunk = []
        end
        if ctr <= numperchunk
          chunk << [c,d]
        end
        if ctr == numperchunk
          @chunks << chunk
          chunk = []
          ctr = 0
        end
        ctr+=1
      end
      if ctr < numperchunk and chunk and chunk.length > 0
        @chunks << chunk
      end
    end
  end

  def fans
    @fans = User.active.all(:conditions => 'type <> "Artist"')
  end	
  
  def os_status
    @os = Artist.active.find(:all, :order =>'lastname asc')
    @totals = {}
    @totals['spring 2010'] = @os.select{|a| a.os2010}.length
    @totals['oct 2010'] = @os.select{|a| a.osoct2010}.length
    @totals['spring 2011'] = @os.select{|a| a.os_participation['201104'].nil? ? false : a.os_participation['201104'] }.length
  end
  
  def roles
    @roles = Role.all
    @users = User.active
    @users_in_roles = {}

    @users.each do |u|
      @roles.each do |r|
        k = r.role
        method = "is_#{k}?"
        @users_in_roles[k] = [] if @users_in_roles[k].nil?
        begin 
          @users_in_roles[k] << u if u.send(method)
        rescue NoMethodError => nme
        end
      end
    end
  end

end
