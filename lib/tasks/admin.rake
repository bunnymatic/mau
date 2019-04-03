# frozen_string_literal: true

namespace :admin do
  desc 'remove orphaned art pieces'
  task remove_orphaned_art: [:environment] do
    ArtPiece.includes(:artist).select { |ap| ap.artist.nil? }.each(&:destroy)
  end

  desc 'Migrate open studios participants from the old system to the new'
  task migrate_open_studios_participants: [:environment] do
    OpenStudiosMigrator.new.tap do |migrator|
      puts 'Creating open studios events for previously unrecorded events'
      migrator.create_past_open_studios_events
      puts 'Migrating artists to the new open studios events'
      migrator.migrate_open_studios_participation
    end
  end
end
