# frozen_string_literal: true

require 'elasticsearch/extensions/test/cluster'
class TestEsServer
  DEFAULT_TEST_ARGS = { number_of_nodes: 1, clear_cluster: true }.freeze

  def self.cluster
    Elasticsearch::Extensions::Test::Cluster
  end

  def self.port
    @port ||= URI.parse(Rails.application.config.elasticsearch_url).port
  end

  def self.server_args
    DEFAULT_TEST_ARGS.merge(port: port)
  end

  def self.running?
    cluster.running?(server_args)
  end

  def self.start
    return if running?

    puts "Starting elasticsearch cluster on port #{port}"
    cluster.start(server_args) unless running?
  end

  def self.stop
    puts 'skipping es teardown for speed'
    # puts "Tearing down elastic search cluster on port #{port} if necessary"
    # cluster.stop(port: port) if running?
  end
end
