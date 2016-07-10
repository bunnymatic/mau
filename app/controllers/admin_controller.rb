class AdminController < BaseAdminController

  before_filter :editor_required, :only => [:featured_artist]
  before_filter :admin_required, :except => [:index, :featured_artist]

  layout 'admin'

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
      @featured_artist = ArtistPresenter.new(@featured.try(:artist))
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
    @keys = available_open_studios_keys.map(&:to_s)
    @keys.each do |ostag|
      @totals[ostag] = @os.select{|a| (a.os_participation || {})[ostag] }.length
    end
  end

  def palette
    f = File.expand_path('app/assets/stylesheets/_colors.scss')
    @colors = ScssFileReader.new(f).parse_colors
  end

  private

  def build_list_names_from_params
    list_names = [params[:listname], (params.keys & available_open_studios_keys)].flatten.compact.uniq
    list_names.blank? ? ['active'] : list_names
  end


end
