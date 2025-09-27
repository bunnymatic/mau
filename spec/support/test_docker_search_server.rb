# Methods to check for docker instance of search server at TEST_CLUSTER_URL set in env
class TestDockerSearchServer
  CLUSTER_URL = Rails.application.config.elasticsearch_url

  class << self
    def running?
      response = ping
      warn response if verbose?
      %w[yellow green].include?(response && response['status'])
    end

    private

    def ping
      uri = URI("#{CLUSTER_URL}/_cluster/health")
      warn "Pinging #{uri}" if verbose?
      begin
        response = Net::HTTP.get(uri)
      rescue Exception => e
        warn e.inspect if verbose?
        return nil
      end
      JSON.parse(response)
    end

    def verbose?
      ENV['DEBUG'].presence
    end
  end
end
