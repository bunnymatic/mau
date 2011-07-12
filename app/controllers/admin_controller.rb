class AdminController < ApplicationController
  before_filter :admin_required
  layout 'mau-admin'
  def index
    @activity_stats = {}
    created_clause = "created_at >= ?"
    queries = {:last_30_days => [created_clause, 30.days.ago],
      :last_week =>[created_clause,1.week.ago],
      :yesterday =>[created_clause,1.day.ago]}
    queries.keys.each do |k|
      @activity_stats[k] = {} unless @activity_stats.has_key? k
      @activity_stats[k][:art_pieces_added] = ArtPiece.count(:all, :conditions => queries[k])
      @activity_stats[k][:artists_added] = Artist.count(:all, :conditions => queries[k])
      @activity_stats[k][:artists_activated] = Artist.active.count(:all, :conditions => queries[k])
      @activity_stats[k][:fans_added] = MAUFan.count(:all, :conditions => queries[k])
      @activity_stats[k][:favorites_added] = Favorite.count(:all, :conditions => queries[k])
    end
    @activity_stats[:total] = {:actived_artists => Artist.active.count, 
      :art_pieces_added => ArtPiece.count,
      :accounts => User.count,
      :fans => MAUFan.count,
      :artists => Artist.count,
      :favorited_art_pieces => Favorite.art_pieces.count,
      :favorited_artists => Favorite.artists.count,
      :users_using_favorites => Favorite.count(:select => 'distinct user_id'),
      :pending_artists => Artist.count(:conditions => "state='pending'"),
      :no_profile_image => Artist.active.count(:conditions => "profile_image is not null"),
      :spring_os_2011_participants => Artist.active.open_studios_participants('201104').count,
      :studios => Studio.count
    }
    
  end

  def admin_emails
    @artists = Artist.find(:all, :conditions => ['state="active"'])
  end

  def featured_artist
    featured = FeaturedArtistQueue.current_entry
    if request.post?
      next_featured = FeaturedArtistQueue.next_entry
      @featured = next_featured
      if FeaturedArtistQueue.count != 1 && (featured == next_featured)
        flash.now[:error] = "It looks like #{@featured.artist.get_name(true)} hasn\'t been featured for a full week yet."
      else 
        flash.now[:notice] = "Featuring : #{@featured.artist.get_name(true)} until #{(Time.now + 1.week).strftime('%a %D')}"
      end
    else
      @featured = featured
    end
    @featured_artist = @featured.artist if @featured
    @already_featured = FeaturedArtistQueue.featured[1..-1]
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
    
    invalid_roles = ['a', 'nil']
    @users.each do |u|
      @roles.compact.reject{|role| invalid_roles.include? role.role}.each do |r|
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

  def art_pieces_per_day
    apd = compute_art_pieces_per_day
    result = { :series => [ { :data => apd }],
      :options => {
        :mouse => { :track => true }
      }
    }
    render :json => result
  end

  def favorites_per_day
    apd = compute_favorites_per_day
    result = { :series => [ { :data => apd }],
      :options => {
        :mouse => { :track => true }
      }
    }
    render :json => result
  end
  
  def artists_per_day
    apd = compute_artists_per_day
    result = { :series => [ { :data => apd }],
      :options => {
        :mouse => { :track => true }
      }
    }
    render :json => result
  end

  private
  def compute_artists_per_day
    sql = ActiveRecord::Base.connection()
    tbl = []
    cur = sql.execute "select count(*) ct,date(activated_at) d from users where activated_at is not null group by d order by d desc;"
    ctr = 0
    cur.each_hash do |h|
      tbl << [Time.parse(h['d']).to_i, h['ct'].to_i]
    end
    tbl
  end

  def compute_favorites_per_day
    compute_created_per_day :favorites
  end

  def compute_art_pieces_per_day
    compute_created_per_day :art_pieces
  end

  def compute_created_per_day(tablename)
    sql = ActiveRecord::Base.connection()
    tbl = []
    query =  "select count(*) ct,date(created_at) d from #{tablename} where created_at is not null group by d order by d desc;"
    cur = sql.execute query
    cur.each_hash do |h|
      tbl << [Time.parse(h['d']).to_i, h['ct'].to_i]
    end
    tbl
  end

end
