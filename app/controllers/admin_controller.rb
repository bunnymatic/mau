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
    list_names = build_list_names_from_params
    @email_list = AdminEmailList.new(list_names)

    respond_to do |format|
      format.html {}
      format.csv {
        render_csv_string(@email_list.csv, @email_list.csv_filename)
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

  def build_list_names_from_params
    list_names = [params[:listname], (params.keys & os_tags)].flatten.compact.uniq
    list_names.blank? ? ['active'] : list_names
  end

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

  def os_tags
    @os_tags ||= Conf.open_studios_event_keys.map(&:to_s)
  end

end
