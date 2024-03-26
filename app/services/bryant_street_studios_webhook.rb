class BryantStreetStudiosWebhook
  def self.artist_updated(artist_id)
    post_webhook("/artist/#{artist_id}/update")
  end

  class << self
    private

    def post_webhook(path)
      return false unless activated?

      conn = Faraday.new(url(path)) do |c|
        c.use FaradayMiddleware::FollowRedirects, limit: 3
        c.adapter :typhoeus
      end
      # Faraday (or someone) turns this into HTTP_BSS_API_AUTHORIZATION
      # so watch it!
      headers = {
        'bss-api-authorization' => Conf.bryant_street_studios_api_key,
      }
      response = conn.post(url(path), nil, headers)
      success = response.status == 200
      Rails.logger.warn("Failed to update artist: http code #{response.status}") unless success
      success
    rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed
      Rails.logger.error('Connection failed trying to post to the webhook')
      false
    rescue StandardError => e
      Rails.logger.error('Something went wrong posting the webhook')
      Rails.logger.error(e)
      false
    end

    def activated?
      Conf.bryant_street_studios_webhook_url.present? && Conf.bryant_street_studios_api_key.present?
    end

    def url(path)
      Conf.bryant_street_studios_webhook_url + path
    end
  end
end
