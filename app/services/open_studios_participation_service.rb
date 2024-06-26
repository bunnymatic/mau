# manage caching the list of open studios events
class OpenStudiosParticipationService
  def self.participate(artist, open_studios_event)
    return unless open_studios_event

    OpenStudiosParticipant.transaction do
      artist.open_studios_participants.create(open_studios_event:) unless artist.open_studios_participants.find_by(open_studios_event:)
    end
  end

  def self.refrain(artist, open_studios_event)
    return unless open_studios_event

    artist.open_studios_participants.where(open_studios_event:).destroy_all
  end
end
