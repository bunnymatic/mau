module Search
  module Jobs
    class ArtPiece < ApplicationJob
      queue_as :es_indexer

      def perform(art_piece_id, method)
        art_piece = ::ArtPiece.find_by(id: art_piece_id)
        unless art_piece
          Rails.logger.warn("Unable to find ArtPiece##{object_id} - skipping es indexing")
          return
        end

        Search::Indexer::ArtPieceSearchService.new(art_piece).send(method)
      end
    end
  end
end
