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
      Search::Indexer.delete_index(model)
    end
  end

  desc 'create indices'
  task create_indices: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      puts "Creating index: #{model.index_name}"
      Search::Indexer.create_index(model)
    rescue OpenSearch::Transport::Transport::Errors::BadRequest => e
      # swallow already exists errors
      raise unless e.to_s.include? 'resource_already_exists_exception'
    end
  end
end
