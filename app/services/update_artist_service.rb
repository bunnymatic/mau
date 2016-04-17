class UpdateArtistService

  include OpenStudiosEventShim

  def initialize(artist, params)
    @artist = artist
    @params = params
  end

  def update
    if @params[:artist_info_attributes]
      @params[:artist_info_attributes][:open_studios_participation] = @artist.artist_info.open_studios_participation
    end

    @artist.assign_attributes(@params)
    changes = @artist.changes
    success = @artist.save
    trigger_user_change_event(changes) if changes.present?
    if success
      refresh_in_search_index
    end
    success
  end

  def update_os_status
    participating = (@params[:os_participation].to_i != 0)

    if participating != @artist.doing_open_studios?
      unless @artist.address.blank?
        @artist.update_os_participation(OpenStudiosEventService.current, participating)
        trigger_os_signup_event(participating)
        refresh_in_search_index
      end
    end
    participating
  end

  private

  def trigger_user_change_event(changes)
    changes.each do |field, change|
      old_value, new_value = change
      msg = "#{@artist.full_name} changed their #{field} from #{old_value} to #{new_value}"
      data = {'user' => @artist.login, 'user_id' => @artist.id}
      UserChangedEvent.create(message: msg, data: data)
    end
  end

  def trigger_os_signup_event(participating)
    msg = "#{@artist.full_name} set their os status to" +
          " #{participating} for #{current_open_studios_key} open studios"
    data = {'user' => @artist.login, 'user_id' => @artist.id}
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
