module SearchServerIndexer
  def reindex_search_server
    [Artist, Studio, ArtPiece].each { |clz| SearchService.reindex_all(clz) }
  end
end

RSpec.configure do |config|
  config.include SearchServerIndexer
end
