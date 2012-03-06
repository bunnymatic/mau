### helper methods to encode/decode cookies which are actually hashes
module CookiesHelper
  def self.encode_cookie( hsh )
    begin
      v = Base64.encode64(JSON.generate(hsh))
    rescue
      RAILS_DEFAULT_LOGGER.error("Failed to encode %s for cookie" % hsh)
      return ""
    end
    v
  end
  
  def self.decode_cookie( str )
    begin
      v = JSON.parse(Base64.decode64(str))
    rescue
      RAILS_DEFAULT_LOGGER.error("Failed to decode %s for cookie" % str)
      return {}
    end
    v
  end
end

