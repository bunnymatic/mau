module Search
  module Jobs
    class Artist < ApplicationJob
      queue_as :es_indexer

      def perform(artist_id, method)
        artist = ::Artist.find_by(id: artist_id)
        unless artist
          Rails.logger.warn("Unable to find Artist##{object_id} - skipping es indexing")
          return
        end

        Search::Indexer::ArtistSearchService.new(artist).send(method)
      end
    end
  end
end
