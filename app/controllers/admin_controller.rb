class AdminController < BaseAdminController

  before_filter :editor_required, :only => [:featured_artist]
  before_filter :admin_required, :except => [:index, :featured_artist]

  def index
    @activity_stats = SiteStatistics.new
  end

  def featured_artist
    if request.post?
      @featured = FeaturedArtistQueue.next_entry(params['override'])
      if FeaturedArtistQueue.count == 1
        flash[:notice] = "Featuring : #{@featured.artist.get_name(true)}"+
          " until #{(Time.zone.now + 1.week).strftime('%a %D')}"
      end
      redirect_to request.url
    else
      @featured = FeaturedArtistQueue.current_entry
      @featured_artist = @featured.try(:artist)
      @already_featured = FeaturedArtistQueue.featured.offset(1).first(10)
    end
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
    @os = Artist.active.by_lastname
    @totals = {}
    available_open_studios_keys.map(&:to_s).each do |ostag|
      key = OpenStudiosEvent.for_display(ostag)
      @totals[key] = @os.count{|a| (a.os_participation || {})[ostag] }
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
    tally = OpenStudiosTally.where(:oskey => current_open_studios_key)
    tally = tally.map{|t| [ t.recorded_on.to_time.to_i, t.count ]}

    result = { :series => [{ :data => tally }],
      :options => {
        :mouse => { :track => true }
      }
    }
    render :json => result
  end

  def palette
    f = File.expand_path('app/assets/stylesheets/_colors.scss')
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
    list_names = [params[:listname], (params.keys & available_open_studios_keys)].flatten.compact.uniq
    list_names.blank? ? ['active'] : list_names
  end

  def compute_artists_per_day
    cur = Artist.active.
      where("adddate(activated_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW()").
      group("date(activated_at)").
      order("activated_at desc").count
    cur.select{|k,v| k.present?}.map{|k,v| [k.to_time, v].map(&:to_i)}
  end

  def compute_favorites_per_day
    compute_created_per_day Favorite
  end

  def compute_art_pieces_per_day
    compute_created_per_day ArtPiece
  end

  def compute_created_per_day(clz)
    cur = clz.where("adddate(created_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW()").
      group("date(created_at)").
      order("created_at desc").count
    cur.select{|k,v| k.present?}.map{|k,v| [k.to_time, v].map(&:to_i)}
  end

end
