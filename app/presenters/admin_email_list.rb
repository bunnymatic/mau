require 'csv'
class AdminEmailList < ViewPresenter
  BASE_COLUMN_HEADERS = ['First Name', 'Last Name', 'Full Name', 'Email Address', 'Group Site Name'].freeze

  attr_accessor :list_names

  def initialize(list_names)
    super()
    @list_names = [list_names].flatten.map(&:to_s)
  end

  def available_open_studios_events
    @available_open_studios_events ||= OpenStudiosEvent.all
  end

  def available_open_studios_keys
    available_open_studios_events.pluck(:key).sort
  end

  def csv_filename
    @csv_filename ||= "#{(['email'] + list_names).compact.uniq.join('_')}.csv"
  end

  def artists
    @artists ||= (multi_os_query? ? os_participants : artists_by_list) || []
  end

  def emails
    @emails ||= artists.select { |a| a.email.present? }.map do |a|
      OpenStruct.new(
        id: a.id,
        name: a.get_name,
        email: a.email,
        activated_at: a.activated_at,
        last_login: a.last_login_at,
        link: url_helpers.artist_path(a.slug),
      )
    end
  end

  def display_title
    @display_title ||= "#{title} [#{artists.length}]"
  end

  def title
    @title ||= (list_names.map { |n| titles[n.to_s] }.join ', ')
  end

  def os_participants
    @os_participants ||=
      begin
        artist_list = OpenStudiosEventService.where(key: queried_os_tags).map(&:artists)
        inlist = artist_list.shift
        artist_list.each do |l|
          inlist |= l
        end
        inlist
      end
  end

  def csv
    @csv ||=
      begin
        CSV.generate(DEFAULT_CSV_OPTS) do |csv|
          csv << csv_headers
          artists.each do |artist|
            csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def artists_by_list
    list_name = list_names.first
    case list_name
    when 'fans'
      MauFan.all
    when 'all'
      Artist.all
    when 'active', 'pending'
      Artist.send(list_names.first).all
    when 'no_profile'
      Artist.active.where(profile_image: nil)
    when 'no_images'
      Artist.active.reject { |a| a.art_pieces.count.positive? }
    when *available_open_studios_keys
      OpenStudiosEventService.find_by_key(list_name).try(:artists).presence || []
    end
  end

  def lists
    @lists ||=
      begin
        os_lists = available_open_studios_keys.reverse.map do |ostag|
          [ostag, OpenStudiosEventService.for_display(ostag)]
        end

        [%w[all Artists],
         %w[active Activated],
         %w[pending Pending],
         %w[fans Fans],
         ['no_profile', 'Active with no profile image'],
         ['no_images', 'Active with no art']] + os_lists
      end
  end

  private

  def titles
    @titles ||= Hash[lists]
  end

  def queried_os_tags
    @queried_os_tags ||= (list_names & available_open_studios_keys)
  end

  def multi_os_query?
    list_names.present? && queried_os_tags.present?
  end

  def csv_headers
    @csv_headers ||= BASE_COLUMN_HEADERS + available_open_studios_keys
  end

  def artist_as_csv_row(artist)
    [
      csv_safe(artist.firstname),
      csv_safe(artist.lastname),
      artist.get_name(escape: false),
      artist.email,
      artist.studio ? artist.studio.name : '',
    ] + available_open_studios_events.map do |os_event|
      os_event.open_studios_participants.exists?(user: artist)
    end
  end
end
