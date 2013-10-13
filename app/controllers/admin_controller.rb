class AdminController < ApplicationController
  before_filter :admin_required, :except => [:index, :featured_artist]
  before_filter :editor_or_manager_required, :only => [:index]
  before_filter :editor_required, :only => [:featured_artist]
  layout 'mau-admin'
  include OsHelper
  def index
    @os_pretty = os_pretty
    @activity_stats = {}
    created_clause = "created_at >= ?"
    queries = {:last_30_days => [created_clause, 30.days.ago],
      :last_week =>[created_clause,1.week.ago],
      :yesterday =>[created_clause,1.day.ago]}
    queries.keys.each do |k|
      @activity_stats[k] = {} unless @activity_stats.has_key? k
      @activity_stats[k][:art_pieces_added] = ArtPiece.where(queries[k]).count
      @activity_stats[k][:artists_added] = Artist.where(queries[k]).count
      @activity_stats[k][:artists_activated] = Artist.active.where(queries[k]).count
      @activity_stats[k][:fans_added] = MAUFan.where(queries[k]).count
      @activity_stats[k][:favorites_added] = Favorite.where(queries[k]).count
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
      :favorites_users_using => Favorite.group('user_id').all.count,
      :artists_pending => Artist.where(:state => 'pending').count,
      :artists_no_profile_image => Artist.active.where("profile_image is not null").count,
      :studios => Studio.count
    }
    @activity_stats[:open_studios] = {}
    Conf.open_studios_event_keys.map(&:to_s).each do |ostag|
      key = os_pretty(ostag)
      @activity_stats[:open_studios][key] = Artist.active.open_studios_participants(ostag).count
    end
  end

  def featured_artist
    featured = FeaturedArtistQueue.current_entry
    if request.post?
      next_featured = FeaturedArtistQueue.next_entry(params['override'])
      @featured = next_featured
      if FeaturedArtistQueue.count == 1
        flash[:notice] = "Featuring : #{@featured.artist.get_name(true)} until #{(Time.zone.now + 1.week).strftime('%a %D')}"
      end
      redirect_to request.url
      return
    else
      @featured = featured
    end
    @featured_artist = @featured.artist if @featured
    @already_featured = (FeaturedArtistQueue.featured[1..-1] || []).first(10)
  end

  def emaillist
    artists = []
    arg = params[:listname] || 'active'
    @lists = [[ :all, 'Artists'],
              [ :active, 'Activated'],
              [ :pending, 'Pending'],
              [ :fans, 'Fans' ],
              [ :no_profile, 'Active with no profile image'],
              [ :no_images, 'Active with no artwork']
              ]
    os_tags = Conf.open_studios_event_keys.map(&:to_s)
    os_tags.reverse.each do |ostag|
      title = os_pretty(ostag)
      @lists << [ ostag.to_sym, title ]
    end
    titles = Hash[ @lists ]
    if (params.keys & os_tags).present?
      for_title = []
      tags = os_tags & params.keys
      artists = []
      tags.each do |tag|
        for_title << os_pretty(tag)
        artists += Artist.active.open_studios_participants(tag)
      end
      artists.uniq!
      @title = "OS Participants [#{for_title.join(', ')}]"

    else
      @title = titles[arg.to_sym]
      case arg
      when 'fans'
        artists = MAUFan.all
      when *os_tags
        artists = Artist.active.open_studios_participants(arg)
      when 'all'
        artists = Artist.all
      when 'active', 'pending'
        artists = Artist.send(arg).all
      when 'no_profile'
        artists = Artist.active.where("profile_image is null")
      when 'no_images'
        sql = ActiveRecord::Base.connection()
        query = "select id from users where state='active' and id not in (select distinct artist_id from art_pieces);"
        cur = sql.execute query
        aids = cur.map {|h| h.first}
        artists = Artist.where(:id => aids)
      end
    end
    @emails = []
    artists.each do |a|
      entry = { :id => a.id, :name => a.get_name, :email => a.email }
      @emails << entry
    end
    respond_to do |format|
      format.html { render }
      format.csv {
        fname = 'email'
        if params[:listname].present?
          fname += '_' + params[:listname]
        end
        render_csv :filename => fname do |csv|
          csv << ["First Name","Last Name","Full Name", "Email Address", "Group Site Name"] + os_tags
          artists.each do |artist|
            data = [ artist.csv_safe(:firstname), artist.csv_safe(:lastname), artist.get_name(true),artist.email, artist.studio ? artist.studio.name : '' ]
            os_tags.each do |ostag|
              data << artist.os_participation[ostag]
            end
            csv << data
          end
        end
      }
    end

  end

  def fans
    @fans = User.active.where('type <> "Artist"')
  end

  def os_status
    @os = Artist.active.order('lastname asc')
    @totals = {}
    Conf.open_studios_event_keys.map(&:to_s).each do |ostag|
      key = os_pretty(ostag)
      @totals[key] = @os.select{|a| a.os_participation[ostag].nil? ? false : a.os_participation[ostag] }.length
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

  def os_signups
    tally = OpenStudiosTally.where(:oskey => Conf.oslive)
    tally = tally.map{|t| [ t.recorded_on.to_time.to_i, t.count ]}

    result = { :series => [{ :data => tally }],
      :options => {
        :mouse => { :track => true }
      }
    }
    render :json => result
  end

  def palette
    f = File.expand_path('app/assets/stylesheets/mau-mixins.scss')
    @colors = ScssFileReader.new(f).parse_colors
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
  GRAPH_LOOKBACK = '1 YEAR'
  def compute_artists_per_day
    sql = ActiveRecord::Base.connection()
    cur = sql.execute "select count(*) ct,date(activated_at) d from users where activated_at is not null and adddate(activated_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW() group by d order by d desc;"
    cur.map{|h| [h[1].to_time.to_i, h[0].to_i]}
  end

  def compute_favorites_per_day
    compute_created_per_day :favorites
  end

  def compute_art_pieces_per_day
    compute_created_per_day :art_pieces
  end

  def compute_created_per_day(tablename)
    sql = ActiveRecord::Base.connection()
    query =  "select count(*) ct,date(created_at) d from #{tablename} where created_at is not null and adddate(created_at,INTERVAL #{GRAPH_LOOKBACK}) > NOW() group by d order by d desc;"
    cur = sql.execute query
    cur.map{|h| [h[1].to_time.to_i, h[0].to_i]}
  end

end
