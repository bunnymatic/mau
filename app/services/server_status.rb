# frozen_string_literal: true

class ServerStatus
  def self.run
    {
      version: Mau::Version::VERSION,
      main: site_up?,
      elasticsearch: elasticsearch_up?
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
      response = Faraday.get(url)
      response.status == 200
    rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed
      false
    end
  end
end
