class SiteStatistics

  attr_accessor :last_30_days, :last_week, :yesterday, :totals, :open_studios

  include OpenStudiosEventShim

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
  ACTIVATED_CLAUSE = "activated_at >= ?"
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
    @totals ||= {}.tap do |tally|
      %w( art_pieces_stats favorites_stats studios_stats artists_stats events_stats other_users_stats).each do |m|
        tally.merge!(send(m))
      end
    end
  end

  def art_pieces_stats
    {:art_pieces_added => ArtPiece.count}
  end

  def favorites_stats
    {
      :favorited_art_pieces => Favorite.art_pieces.count,
      :favorited_artists => Favorite.artists.count,
      :favorites_users_using => Favorite.group('user_id').all.count,
    }
  end

  def studios_stats
    {:studios => Studio.count}
  end

  def artists_stats
    { :actived_artists => Artist.active.count,
      :artists_pending => Artist.pending.count,
      :artists_no_profile_image => Artist.active.where("profile_image is not null").count,
      :artists => Artist.count,
    }
  end

  def other_users_stats
    {
      :accounts => User.count,
      :fans => MAUFan.count
    }
  end

  def events_stats
    {
      :events_past => Event.past.count,
      :events_future => Event.future.count
    }
  end

  def compute_os_stats
    @as_stats ||= available_open_studios_keys.map(&:to_s).each do |ostag|
      key = OpenStudiosEvent.pretty_print(ostag)
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
