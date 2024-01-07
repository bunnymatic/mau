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
      headers = {
        'bss-api-authorization' => Conf.bryant_street_studios_api_key,
      }
      response = conn.post(url(path), {}, headers)
      response.status == 200
    rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed
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
