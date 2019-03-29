# frozen_string_literal: true

namespace :admin do
  desc 'remove orphaned art pieces'
  task remove_orphaned_art: [:environment] do
    ArtPiece.includes(:artist).select { |ap| ap.artist.nil? }.each(&:destroy)
  end
  task migrate_open_studios_participants: [:environment] do
    os_events = OpenStudiosEvent.all.each_with_object({}) do |entry, memo|
      memo[entry.key] = entry
    end
    infos = ArtistInfo.where.not(open_studios_participation: nil)
    infos.each do |info|
      os = info.os_participation.select { |_key, val| val }.map(&:first)
      os.each do |key|
        event = os_events[key]
        puts "#{event.key} #{info.artist.login}"
        OpenStudiosParticipant.create(user: info.artist, open_studios_event: event) if event && info.artist
      end
    end
  end
end
