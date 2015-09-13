namespace :es do

  desc 'reindex models'
  task reindex: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      Search::Indexer.reindex(model)
    end
  end

end
