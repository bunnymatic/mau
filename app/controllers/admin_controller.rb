# frozen_string_literal: true

class AdminController < BaseAdminController
  before_action :admin_required, except: [:index]

  layout 'admin'

  def index
    @activity_stats = SiteStatistics.new
  end

  def os_status
    @os = Artist.active.by_lastname
    @open_studios_events = OpenStudiosEvent.all.includes(:open_studios_participants)
    @totals = @open_studios_events.each_with_object({}) do |open_studio, memo|
      memo[open_studio.key] = open_studio.artists.count
    end
  end
end
