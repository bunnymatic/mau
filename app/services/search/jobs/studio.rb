module Search
  module Jobs
    class Studio < ApplicationJob
      queue_as :es_indexer

      def perform(studio_id, method)
        studio = ::Studio.find_by(id: studio_id)
        unless studio
          Rails.logger.warn("Unable to find Studio##{studio_id} - skipping es indexing")
          return
        end

        Search::Indexer::StudioSearchService.new(studio).send(method)
      end
    end
  end
end
