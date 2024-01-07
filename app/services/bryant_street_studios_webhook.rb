class BryantStreetStudiosWebhook
  def self.artist_updated(artist_id)
    webhook(:post, "/artist/#{artist_id}/update")
  end

  def self.webhook(method, path)
    conn = Faraday.new(url(path)) do |c|
      c.use FaradayMiddleware::FollowRedirects, limit: 3
      c.adapter :typhoeus
    end
    headers = {
      'bss-api-authorization': Conf.bryant_street_studios_api_key,
    }
    response = conn.send(method, url(path), headers:)
    response.status == 200
  rescue Errno::ECONNREFUSED, Faraday::ConnectionFailed
    false
  end

  private

  def self.url(path)
    Conf.bryant_street_studios_webhook_url + path
  end
end
