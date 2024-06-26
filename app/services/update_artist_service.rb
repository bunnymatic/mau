class UpdateArtistService
  class Error < StandardError; end

  attr_reader :artist, :params, :file, :current_os

  def initialize(artist, params)
    @artist = artist
    @params = params
    @current_os = OpenStudiosEventService.current
    @file = params.delete(:photo)

    raise UpdateArtistService::Error, 'artist cannot be nil' unless artist
    raise UpdateArtistService::Error, 'artist must be an artist' unless artist.artist?
  end

  def update
    success = nil
    Artist.transaction do
      artist.artist_info.assign_attributes(params.delete(:artist_info_attributes) || {})
      artist.assign_attributes(params)
      changes = artist.changes.merge(artist.artist_info.changes)
      artist.slug = nil if changes[:login]
      artist.photo.attach(file) if file
      success = artist.save

      trigger_user_change_event(changes) if changes.present?
    end
    refresh_in_search_index if success
    notify_bryant_street_studios if success
    success
  end

  def update_os_status
    participating = to_boolean(params[:os_participation])
    if participating != artist.doing_open_studios?
      if participating
        OpenStudiosParticipationService.participate(artist, @current_os)
      else
        OpenStudiosParticipationService.refrain(artist, @current_os)
      end
      trigger_os_signup_event(participating)
      refresh_in_search_index
      ArtistMailer.welcome_to_open_studios(artist, @current_os).deliver_later if participating
    end
    artist.current_open_studios_participant
  end

  private

  def to_boolean(val)
    return false if val.nil?
    return val if !!val == val # is a boolean
    return true if val.casecmp('true').zero?

    val.to_i != 0
  end

  def trigger_user_change_event(changes)
    msg = sprintf("#{artist.full_name} updated %s", changes.map(&:first).to_sentence)
    formatted_changes = changes.transform_values do |change|
      sprintf('%s => %s', *change)
    end

    UserChangedEvent.create(message: msg, data: { changes: formatted_changes, user: artist.login, user_id: artist.id })
  end

  def trigger_os_signup_event(participating)
    msg = "#{artist.full_name} set their os status to " \
          "#{participating} for #{@current_os.for_display(month_first: true)} open studios"
    data = { user: artist.login, user_id: artist.id }
    OpenStudiosSignupEvent.create(message: msg,
                                  data:)
  end

  def notify_bryant_street_studios
    BryantStreetStudiosWebhook.artist_updated(artist.id)
  end

  def refresh_in_search_index
    if artist.active?
      Search::Indexer.update(artist)
    else
      Search::Indexer.remove(artist)
    end
  end
end
