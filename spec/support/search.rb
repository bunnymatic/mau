require_relative 'test_search_server'

module RSpec
  module Search
    module Elasticsearch
      ES_METHODS = {
        index_document: nil,
        delete_document: nil,
        update_document: nil,
      }.freeze
      def elasticsearch_double(name:, stubs: nil)
        stubs = (stubs || {}).merge(ES_METHODS)
        name ||= 'EsDouble'
        double(name, stubs)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Search::Elasticsearch

  config.before do |example|
    search_setting = example.metadata[:search]&.to_sym
    case search_setting
    when :none
      # do nothing
      nil
    when :opensearch, :elasticsearch
      begin
        TestSearchServer.start unless ENV['CI'] || ENV['DOCKER_OPENSEARCH']
      rescue Exception => e
        puts "Failed to start search server: #{e}"
      end
    when :elasticsearch_stub
      allow(FeatureFlags).to receive(:use_open_search?).and_return false
      [Artist, Studio, ArtPiece].each do |clz|
        mock = elasticsearch_double(name: "EsDoubleFor#{clz.name}")
        allow_any_instance_of(clz).to receive('__elasticsearch__').and_return mock
      end
    when :opensearch_stub
      allow(FeatureFlags).to receive(:use_open_search?).and_return true
      methods = %i[index update reindex remove reindex_all create_index delete_index multi_index_search search]

      methods.each do |method|
        allow(Search::OpenSearch::SearchService).to receive(method)
      end
    else
      # intercept search service calls
      methods = %i[index update reindex remove reindex_all create_index delete_index multi_index_search search]

      methods.each do |method|
        allow(Search::SearchService).to receive(method)
      end
    end
  end
end

at_exit do
  TestSearchServer.stop unless ENV['CI'] || ENV['DOCKER_OPENSEARCH']
rescue Exception => e
  puts "Failed to stop Elasticsearch: #{e}"
end
