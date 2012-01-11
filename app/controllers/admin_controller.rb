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
      :events_past => Event.past.count,
      :events_future => Event.future.count,
      :favorited_art_pieces => Favorite.art_pieces.count,
      :favorited_artists => Favorite.artists.count,
      :favorites_users_using => Favorite.count(:select => 'distinct user_id'),
      :artists_pending => Artist.count(:conditions => "state='pending'"),
      :artists_no_profile_image => Artist.active.count(:conditions => "profile_image is not null"),
      :studios => Studio.count
    }
    @activity_stats[:open_studios] = {}
    Conf.open_studios_event_keys.map(&:to_s).each do |ostag|
      yr = ostag[0..3]
      mo = ostag[4..-1]
      seas = (mo == '10') ? 'Oct':'Apr'
      key = "%s %s" % [ yr, seas ]
      @activity_stats[:open_studios][key] = Artist.active.open_studios_participants(ostag).count
    end
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
    when 'october2011'
      @title = "Fall 2011 OS Set"
      artists = Artist.active.open_studios_participants('201110')
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
      cur.each do |h|
        aids << h[0]
      end
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
    Conf.open_studios_event_keys.map(&:to_s).each do |ostag|
      yr = ostag[0..3]
      mo = ostag[4..-1]
      seas = (mo == '10') ? 'fall':'spring'
      key = "%s %s" % [ seas, yr ]
      @totals[key] = @os.select{|a| a.os_participation[ostag].nil? ? false : a.os_participation[ostag] }.length
    end
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

  def palette

    css_file = File.expand_path('public/stylesheets/sass/mau-mixins.scss')
    css_data = []
    File.open(css_file, 'r').each do |line|
      if /\$(.*)\:\s*\#(.*)\;/.match(line.strip)
        css_data << [$1, $2]
      end
    end
    @colors = css_data

  end
  
  def db_backups
    @dbfiles = Dir.glob(File.join(Rails.root, 'backups/**/*.tgz')).map{|f| File.new(f)}.sort_by(&:ctime).reverse
  end
  
  def fetch_backup
    ### don't allow downloading of anything - only db backup files
    available_backup_files = Dir.glob(File.join(Rails.root, 'backups/**/*.tgz'))
    unless params[:name].present?
      redirect_to admin_path(:action => 'db_backups')
      return
    end
    filename = File.basename(params[:name])
    backup_file = available_backup_files.select{|f| File.basename(f) == params[:name]}.first
    if backup_file.present?
      send_file backup_file
    else
      redirect_to admin_path(:action => 'db_backups')
      return
    end
  end    

  private
  def compute_artists_per_day
    sql = ActiveRecord::Base.connection()
    tbl = []
    cur = sql.execute "select count(*) ct,date(activated_at) d from users where activated_at is not null group by d order by d desc;"
    ctr = 0
    cur.each do |h|
      tbl << [h[1].to_time.to_i, h[0].to_i]
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
    cur.each do |h|
      tbl << [h[1].to_time.to_i, h[0].to_i]
    end
    tbl
  end

end
