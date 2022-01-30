require 'csv'

class AdminArtistList < ViewPresenter
  def good_standing_artists
    artists.active.order(updated_at: :desc)
  end

  def pending_artists
    artists.pending.order(updated_at: :desc)
  end

  def bad_standing_artists
    artists.bad_standing.order(updated_at: :desc)
  end

  def csv_headers
    headers = [
      'Login',
      'First Name',
      'Last Name',
      'Full Name',
      'Group Site Name',
      'Studio Address',
      'Studio Number',
      'Email Address',
      'Phone',
    ]
    if OpenStudiosEvent.current
      headers << "Participating in Open Studios #{OpenStudiosEvent.current.for_display}" if OpenStudiosEvent.current
    else
      headers << 'No Current Open Studios'
    end
    headers << 'Since'
    headers << 'Last Seen'
    headers << 'Last Updated Profile'
    headers + open_studios_event_headers
  end

  def open_studios_event_headers
    [
      'Show Phone',
      'Show Email',
      'Shop Url',
      'Youtube Url',
      'Video Conference Url',
    ] + time_slot_headers
  end

  def time_slot_headers
    Time.use_zone(Conf.event_time_zone) do
      headers = (current_os&.special_event_time_slots || []).map do |slot|
        OpenStudiosParticipant.parse_time_slot(slot).first
      end
      headers.map { |start_time| start_time.to_s(:admin_with_zone) }
    end
  end

  def csv
    @csv ||=
      CSV.generate(**DEFAULT_CSV_OPTS) do |csv|
        csv << csv_headers
        artists.all.each do |artist|
          csv << artist_as_csv_row(ArtistPresenter.new(artist))
        end
      end
  end

  def csv_filename
    'mau_artists.csv'
  end

  private

  def artists
    Artist.includes(:artist_info, :studio, :art_pieces, :open_studios_participants)
  end

  def current_os
    @current_os ||= OpenStudiosEvent.current
  end

  def artist_as_csv_row(artist)
    Time.use_zone(Conf.event_time_zone) do
      [
        csv_safe(artist.login),
        csv_safe(artist.firstname),
        csv_safe(artist.lastname),
        csv_safe(artist.get_name),
        artist.studio&.name || '',
        artist.address&.street || '',
        artist.studionumber,
        artist.email,
        artist.phone,
        artist.doing_open_studios?,
        artist.member_since_date.to_s(:admin_date_only),
        artist.last_login,
        artist.last_updated_profile,
      ] + open_studios_participant_as_csv_row(artist.current_open_studios_participant)
    end
  end

  def open_studios_participant_as_csv_row(participant)
    os = OpenStudiosEvent.current
    base_attrs = %i[show_phone_number show_email shop_url youtube_url video_conference_url]
    available_time_slots = os&.special_event_time_slots || []

    return Array.new(base_attrs.size + available_time_slots.size, '') unless participant

    row = base_attrs.map { |attr| participant.send(attr) }
    video_schedule = participant.video_conference_schedule
    available_time_slots.map do |slot|
      row << (video_schedule && video_schedule[slot] ? 'true' : '')
    end
    row
  end
end
