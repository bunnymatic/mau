require 'elasticsearch/extensions/test/cluster'
class TestEsServer
  def self.cluster
    Elasticsearch::Extensions::Test::Cluster
  end

  def self.port
    @port ||= URI.parse(Rails.application.config.elasticsearch_url).port
  end

  def self.running?
    cluster.running?(port: self.port)
  end

  def self.start
    if !running?
      puts "Starting elasticsearch cluster on port #{port}"
      cluster.start(port: port, number_of_nodes: 1, clear_cluster: true) unless running?
    end
  end

  def self.stop
    puts "Tearing down elastic search cluster on port #{port} if necessary"
    cluster.stop(port: port) if running?
  end
end
