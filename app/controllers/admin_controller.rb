class AdminController < BaseAdminController

  before_action :editor_required, :only => [:featured_artist]
  before_action :admin_required, :except => [:index, :featured_artist]

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

  def os_status
    @os = Artist.active.by_lastname
    @totals = {}
    @keys = available_open_studios_keys.map(&:to_s)
    @keys.each do |ostag|
      @totals[ostag] = @os.select{|a| (a.os_participation || {})[ostag] }.length
    end
  end

end
