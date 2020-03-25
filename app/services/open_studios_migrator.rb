# frozen_string_literal: true

class OpenStudiosMigrator
  include OpenStudiosEventShim

  def create_past_open_studios_events
    image = Rails.root.join('app/assets/images/debug_os_placeholder.png')

    PAST_OS_EVENT_KEYS.each do |key|
      next if OpenStudiosEvent.find_by(key: key)

      fp = File.open(image, 'rb')
      date = Time.zone.strptime(key, '%Y%m')
      attrs = {
        start_date: date,
        end_date: date + 1.day,
        key: key,
        logo: fp,
      }
      OpenStudiosEvent.create!(attrs)
      fp.close
    end
  end

  def migrate_open_studios_participation
    infos = ArtistInfo.where.not(deprecated_open_studios_participation: nil).includes(:artist)
    os_events = OpenStudiosEvent.all.index_by(&:key)
    infos.each do |info|
      artist = info.artist
      info.deprecated_open_studios_participation.split('|').each do |key|
        event = os_events[key.strip]
        next unless event.present? && artist.present?

        OpenStudiosParticipant.transaction do
          OpenStudiosParticipant.create!(user: artist, open_studios_event: event) unless artist.open_studios_events.find_by(key: key)
        end
      end
    end
  end
end
