# frozen_string_literal: true

namespace :es do
  desc 'reindex models'
  task reindex: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      Search::Indexer.reindex_all(model)
    end
  end
end
