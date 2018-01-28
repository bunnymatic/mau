# frozen_string_literal: true

class AdminController < BaseAdminController
  before_action :admin_required, except: [:index]

  layout 'admin'

  def index
    @activity_stats = SiteStatistics.new
  end

  def os_status
    @os = Artist.active.by_lastname
    @totals = {}
    @keys = available_open_studios_keys.map(&:to_s)
    @keys.each do |ostag|
      @totals[ostag] = @os.select { |a| (a.os_participation || {})[ostag] }.length
    end
  end
end
