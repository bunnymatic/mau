# frozen_string_literal: true

require 'elasticsearch'
require 'elasticsearch/extensions/reindex'

namespace :es do
  desc 'reindex models'
  task reindex: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      Search::Indexer.reindex_all(model)
    end
  end

  desc 'delete indeces'
  task delete_indeces: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      begin
        model.indices.delete index: model.index_name
      rescue StandardError
        nil
      end
    end
  end

  desc 'create indeces'
  task create_indeces: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      begin
        model.indices.create index: model.index_name
      rescue StandardError
        nil
      end
    end
  end
end
