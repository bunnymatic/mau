class AdminController < ApplicationController
  before_filter :admin_required, :except => [:index, :featured_artist]
  before_filter :editor_or_manager_required, :only => [:index]
  before_filter :editor_required, :only => [:featured_artist]
  layout 'mau-admin'
  include OsHelper

  def index
    @os_pretty = os_pretty
    @activity_stats = SiteStatistics.new
  end

  def featured_artist
    featured = FeaturedArtistQueue.current_entry
    if request.post?
      next_featured = FeaturedArtistQueue.next_entry(params['override'])
      @featured = next_featured
      if FeaturedArtistQueue.count == 1
        flash[:notice] = "Featuring : #{@featured.artist.get_name(true)}"+
          " until #{(Time.zone.now + 1.week).strftime('%a %D')}"
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
    listname = params[:listname] || 'active'
    @lists = [[ :all, 'Artists'],
              [ :active, 'Activated'],
              [ :pending, 'Pending'],
              [ :fans, 'Fans' ],
              [ :no_profile, 'Active with no profile image'],
              [ :no_images, 'Active with no artwork']
              ]
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
      @title = titles[listname.to_sym]
      artists = fetch_artists_for_email(listname)
    end
    respond_to do |format|
      format.html {
        @emails = package_artist_emails(artists)
      }
      format.csv {
        fname = 'email'
        if params[:listname].present?
          fname += '_' + params[:listname]
        end
        render_csv :filename => fname do |csv|
          csv << ["First Name","Last Name","Full Name", "Email Address", "Group Site Name"] + os_tags
          artists.each do |artist|
            data = [ artist.csv_safe(:firstname),
                     artist.csv_safe(:lastname),
                     artist.get_name(true),
                     artist.email,
                     artist.studio ? artist.studio.name : '' ]
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
    cur = sql.execute "select count(*) ct,date(activated_at) d from users"+
      " where activated_at is not null and"+
      " adddate(activated_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW() group by d order by d desc;"
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
    query =  "select count(*) ct,date(created_at) d from #{tablename}"+
      " where created_at is not null and"+
      " adddate(created_at,INTERVAL #{GRAPH_LOOKBACK}) > NOW() group by d order by d desc;"
    cur = sql.execute query
    cur.map{|h| [h[1].to_time.to_i, h[0].to_i]}
  end

  def package_artist_emails(artists)
    artists.select{|a| a.email.present?}.map{|a| { :id => a.id, :name => a.get_name, :email => a.email }}
  end

  def os_tags
    @os_tags ||= Conf.open_studios_event_keys.map(&:to_s)
  end

  def fetch_artists_for_email(section)
    case section
    when 'fans'
      MAUFan.all
    when *os_tags
      Artist.active.open_studios_participants(section)
    when 'all'
      Artist.all
    when 'active', 'pending'
      Artist.send(section).all
    when 'no_profile'
      Artist.active.where("profile_image is null")
    when 'no_images'
      sql = ActiveRecord::Base.connection()
      query = "select id from users where " +
        "state='active' and type='Artist' and " +
        "id not in (select distinct artist_id from art_pieces);"
      a_ids = (sql.execute query).map(&:first)
      Artist.where(:id => a_ids)
    end
  end

end
