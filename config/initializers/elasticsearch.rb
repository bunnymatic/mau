[ArtPiece, Studio, Artist].each do |model|
  model.__elasticsearch__.client = Search::EsClient.root_es_client
end
