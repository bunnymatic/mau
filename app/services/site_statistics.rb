# frozen_string_literal: true

class SiteStatistics
  attr_accessor :last_30_days, :last_week, :yesterday, :totals

  include OpenStudiosEventShim

  def initialize
    compute
  end

  def open_studios
    {}.tap do |os_stats|
      available_open_studios_keys.sort_by { |k| OpenStudiosEventService.date(k) }.reverse.each do |ostag|
        key = display_key(ostag)
        os_stats[key] = Artist.active.open_studios_participants(ostag).count
      end
    end
  end

  def social_links
    StatsCalculator::Histogram.new.tap do |social|
      Artist.active.pluck(:links).map(&:compact).each do |links|
        links.each_key do |site|
          social.add(site)
        end
      end
    end
  end

  private

  def display_key(os_key)
    OpenStudiosEventService.for_display(os_key, true)
  end

  def compute
    queries.each_key do |k|
      compute_for_section(k)
    end
    compute_totals
  end

  CREATED_CLAUSE = 'created_at >= ?'
  ACTIVATED_CLAUSE = 'activated_at >= ?'
  LAST_SEEN_CLAUSE = 'last_request_at >= ?'
  LAST_LOGIN_CLAUSE = 'current_login_at >= ?'
  def queries(clause = CREATED_CLAUSE)
    {
      last_30_days: [clause, 30.days.ago],
      last_week: [clause, 1.week.ago],
      yesterday: [clause, 1.day.ago]
    }
  end

  def queries_about_creation
    queries
  end

  def queries_about_activation
    queries(ACTIVATED_CLAUSE)
  end

  def queries_about_last_seen
    queries(LAST_SEEN_CLAUSE)
  end

  def queries_about_login
    queries(LAST_LOGIN_CLAUSE)
  end

  def login_stats
    {}
  end

  def compute_for_section(section)
    add_statistic section, :art_pieces_added, ArtPiece.where(queries[section]).count
    add_statistic section, :artists_added, Artist.where(queries[section]).count
    add_statistic section, :artists_activated, Artist.active.where(queries_about_activation[section]).count
    add_statistic section, :fans_added, MauFan.where(queries[section]).count
    add_statistic section, :favorites_added, Favorite.where(queries[section]).count
    add_statistic section, :user_visits, User.where(queries_about_last_seen[section]).count
    add_statistic section, :user_logins, User.where(queries_about_login[section]).count
  end

  def compute_totals
    @totals ||= {}.tap do |tally|
      %w[art_pieces_stats artists_stats other_users_stats login_stats favorites_stats studios_stats].each do |m|
        tally.merge!(send(m))
      end
    end
  end

  def art_pieces_stats
    { art_pieces_added: ArtPiece.count }
  end

  def favorites_stats
    {
      favorited_art_pieces: Favorite.art_pieces.count,
      favorited_artists: Favorite.artists.count,
      favorites_users_using: Favorite.distinct('user_id').pluck(:user_id).count
    }
  end

  def studios_stats
    { studios: Studio.count }
  end

  def artists_stats
    artist_states = Artist.select(:state).group(:state).count
    { artists_activated: artist_states.fetch('active', 'n/a'),
      artists_pending: artist_states.fetch('pending', 'n/a'),
      artists_without_art: Artist.without_art.count,
      artists_no_profile_image: Artist.active.where('profile_image is not null').count,
      artists: artist_states.values.sum }
  end

  def other_users_stats
    {
      accounts: User.count,
      fans: MauFan.count
    }
  end

  def add_statistic(section, stat, value)
    setter = "#{section}="
    getter = section.to_s
    send(setter, send(getter) || {})
    send(getter)[stat] = value
  end
end
