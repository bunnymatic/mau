module TzHelper
  def in_mau_time t
    t.in_time_zone(Rails.configuration.time_zone)
  end
end
