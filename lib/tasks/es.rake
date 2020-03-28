# frozen_string_literal: true

namespace :es do
  desc 'reindex models'
  task reindex: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      puts "Reindexing #{model}"
      Search::Indexer.reindex_all(model)
    end
  end

  desc 'delete indices'
  task delete_indices: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      puts "Deleting index: #{model.index_name}"
      Search::EsClient.client.indices.delete index: model.index_name
    end
  end

  desc 'create indices'
  task create_indices: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      puts "Creating index: #{model.index_name}"
      Search::EsClient.indices.create index: model.index_name
    end
  end
end
