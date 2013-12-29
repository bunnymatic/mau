class SiteStatistics

  attr_accessor :last_30_days, :last_week, :yesterday, :totals, :open_studios

  include OsHelper

  def initialize
    compute
  end

  private

  def compute
    queries.keys.each do |k|
      compute_for_section(k)
    end
    compute_totals
    compute_os_stats
  end


  CREATED_CLAUSE = "created_at >= ?"
  def queries
    @queries ||= {
      :last_30_days => [CREATED_CLAUSE, 30.days.ago],
      :last_week => [CREATED_CLAUSE,1.week.ago],
      :yesterday => [CREATED_CLAUSE,1.day.ago]
    }
  end

  def compute_for_section(section)
    add_statistic section, :art_pieces_added, ArtPiece.where(queries[section]).count
    add_statistic section, :artists_added, Artist.where(queries[section]).count
    add_statistic section, :artists_activated, Artist.active.where(queries[section]).count
    add_statistic section, :fans_added, MAUFan.where(queries[section]).count
    add_statistic section, :favorites_added, Favorite.where(queries[section]).count
  end

  def compute_totals
    @totals ||= {
      :actived_artists => Artist.active.count,
      :art_pieces_added => ArtPiece.count,
      :accounts => User.count,
      :fans => MAUFan.count,
      :artists => Artist.count,
      :events_past => Event.past.count,
      :events_future => Event.future.count,
      :favorited_art_pieces => Favorite.art_pieces.count,
      :favorited_artists => Favorite.artists.count,
      :favorites_users_using => Favorite.group('user_id').all.count,
      :artists_pending => Artist.pending.count,
      :artists_no_profile_image => Artist.active.where("profile_image is not null").count,
      :studios => Studio.count
    }
  end

  def compute_os_stats
    @as_stats ||= Conf.open_studios_event_keys.map(&:to_s).each do |ostag|
      key = os_pretty(ostag)
      add_statistic :open_studios, key, Artist.active.open_studios_participants(ostag).count
    end
  end

  def add_statistic(section, stat, value)
    setter = "#{section}="
    getter = "#{section}"
    send(setter, send(getter) || {})
    send(getter)[stat] = value
  end
end
