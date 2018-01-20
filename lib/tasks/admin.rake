# frozen_string_literal: true

namespace :admin do
  desc 'remove orphaned art pieces'
  task remove_orphaned_art: [:environment] do
    ArtPiece.includes(:artist).select { |ap| ap.artist.nil? }.each(&:destroy)
  end
end
