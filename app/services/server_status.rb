require 'faraday_middleware'

class ServerStatus
  def self.run
    {
      version: Mau::Version::VERSION,
      main: site_up?,
      elasticsearch: elasticsearch_up?,
    }
  end

  class << self
    private

    def site_up?
      url_check(Rails.application.routes.url_helpers.version_url)
    end

    def elasticsearch_up?
      url_check(Rails.application.config.elasticsearch_url)
    end

    def url_check(url)
      conn = Faraday.new(url) do |c|
        c.use FaradayMiddleware::FollowRedirects, limit: 3
        c.adapter :net_http
      end
      response = conn.get
      response.status == 200
    rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed
      false
    end
  end
end
