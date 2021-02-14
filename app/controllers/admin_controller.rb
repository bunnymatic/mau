class AdminController < BaseAdminController
  before_action :admin_required, except: [:index]

  layout 'admin'

  def index
    @activity_stats = SiteStatistics.new
  end

  def os_status
    @artists = Artist.active.includes(:open_studios_events).by_lastname
    @open_studios_events = OpenStudiosEvent.all.order(start_date: :desc)
    @totals = @open_studios_events.each_with_object({}) do |open_studio, memo|
      memo[open_studio.key] = open_studio.artists.count
    end
  end
end
