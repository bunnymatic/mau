# frozen_string_literal: true

class UpdateArtistService
  include OpenStudiosEventShim

  class Error < StandardError; end

  def initialize(artist, params)
    @artist = artist
    @params = params
    @current_os = OpenStudiosEventService.current
    raise UpdateArtistService::Error, 'artist cannot be nil' unless artist
    raise UpdateArtistService::Error, 'artist must be an artist' unless artist.is_a?(Artist)
  end

  def update
    success = nil
    Artist.transaction do
      @artist.artist_info.assign_attributes(@params.delete(:artist_info_attributes) || {})
      @artist.assign_attributes(@params)
      changes = @artist.changes.merge(@artist.artist_info.changes)
      @artist.slug = nil if changes[:login]

      @artist.slug = nil if changes[:login]
      success = @artist.save
      trigger_user_change_event(changes) if changes.present?
    end
    refresh_in_search_index if success
    success
  end

  def update_os_status
    participating = to_boolean(@params[:os_participation])
    return false unless @artist.can_register_for_open_studios?

    if participating != @artist.doing_open_studios?
      if participating
        OpenStudiosParticipationService.participate(@artist, @current_os)
      else
        OpenStudiosParticipationService.refrain(@artist, @current_os)
      end
      trigger_os_signup_event(participating)
      refresh_in_search_index
      ArtistMailer.welcome_to_open_studios(@artist, @current_os).deliver_later if participating
    end
    participating
  end

  private

  def to_boolean(val)
    return false if val.nil?
    return val if !!val == val # is a boolean
    return true if val.casecmp('true').zero?

    val.to_i != 0
  end

  def trigger_user_change_event(changes)
    changes.each do |field, change|
      old_value, new_value = change
      next unless old_value.present? || new_value.present?

      msg = "#{@artist.full_name} changed their #{field} from " \
            "[#{old_value.to_s.truncate(50)}] to [#{new_value.to_s.truncate(50)}]"
      data = { 'user' => @artist.login, 'user_id' => @artist.id }
      UserChangedEvent.create(message: msg, data: data)
    end
  end

  def trigger_os_signup_event(participating)
    msg = "#{@artist.full_name} set their os status to" \
          " #{participating} for #{@current_os.for_display(true)} open studios"
    data = { 'user' => @artist.login, 'user_id' => @artist.id }
    OpenStudiosSignupEvent.create(message: msg,
                                  data: data)
  end

  def refresh_in_search_index
    if @artist.active?
      Search::Indexer.update(@artist)
    else
      Search::Indexer.remove(@artist)
    end
  end
end
