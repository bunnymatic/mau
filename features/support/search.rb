require_relative '../../spec/support/test_search_server'
require_relative '../../spec/support/test_docker_search_server'
require 'webmock'

class NoSearchServer < StandardError; end

BeforeAll do
  if ENV['DOCKER_OPENSEARCH']
    raise NoSearchServer, 'Make sure your search server is running (probably via docker on 9250)' unless TestDockerSearchServer.running?
  elsif !ENV['CI']
    TestSearchServer.start
    # if !TestSearchServer.ping
    #   raise "No search server - check that you've started the test docker instance (`docker compose up -c docker-compose.test.yml`)"
    # end
    # [Artist, Studio, ArtPiece].each { |clz| Search::SearchService.reindex_all(clz) }
  end
end

at_exit do
  TestSearchServer.stop unless ENV['CI'] || ENV['DOCKER_OPENSEARCH']
rescue Exception => e
  puts "Failed to stop search server #{e}"
end
