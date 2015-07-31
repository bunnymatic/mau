namespace :es do

  desc 'reindex all'
  task reindex_all: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      EsSearchService.new(model).reindex
    end
  end
  
end
