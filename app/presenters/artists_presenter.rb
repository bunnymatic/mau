class ArtistsPresenter

  PER_PAGE = 28

  attr_reader :os_only

  def initialize(view_context, os_only)
    @view_context = view_context
    @os_only = os_only
  end

  def active_artists
    @active_artists ||= Artist.active
  end

  def os_participants
    @os_participants ||= active_artists.open_studios_participants
  end

  def artists
    @artists ||=
      begin
        (if os_only
          os_participants.select(&:in_the_mission?)
        else
          active_artists
        end).sort_by(&:sortable_name)
      end
  end

  def num_artists
    @num_artists ||= artists.length
  end

end
