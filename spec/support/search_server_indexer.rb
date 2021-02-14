module SearchServerIndexer
  def reindex_search_server
    [Artist, Studio, ArtPiece].each { |clz| clz.import force: true }
  end
end

RSpec.configure do |config|
  config.include SearchServerIndexer
end
