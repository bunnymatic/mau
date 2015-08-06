namespace :es do

  desc 'reindex models'
  task reindex: [:environment] do
    [Artist, Studio, ArtPiece].each do |model|
      EsSearchService.new(model).reindex
    end
  end
  
end
