# frozen_string_literal: true

require_relative './test_es_server'

module RSpec
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

RSpec.configure do |config|
  config.include RSpec::Elasticsearch

  config.before do |example|
    case example.metadata[:elasticsearch]
    when true
      begin
        TestEsServer.start unless ENV['CI']
      rescue Exception => ex
        puts "Failed to start Elasticsearch: #{ex}"
      end
    when :stub, 'stub'
      [Artist, Studio, ArtPiece].each do |clz|
        mock = elasticsearch_double(name: "EsDoubleFor#{clz.name}")
        allow_any_instance_of(clz).to receive('__elasticsearch__').and_return mock
      end
    # when false
    else
      # stub elastic search calls
      allow(Search::Indexer).to receive(:index)
      allow(Search::Indexer).to receive(:remove)
      allow(Search::Indexer).to receive(:reindex)
    end
  end
end

at_exit do
  TestEsServer.stop unless ENV['CI']
rescue Exception => ex
  puts "Failed to stop Elasticsearch: #{ex}"
end
