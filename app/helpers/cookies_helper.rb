### helper methods to encode/decode cookies which are actually hashes
module CookiesHelper
  def encode_cookie( hsh )
    begin
      v = Base64.encode64(JSON.generate(hsh))
    rescue
      RAILS_DEFAULT_LOGGER.error('Failed to encode %s for cookie' % hsh)
      return ""
    end
    v
  end
  
  def decode_cookie( str )
    begin
      v = JSON.parse(Base64.decode64(str))
    rescue
      RAILS_DEFAULT_LOGGER.error('Failed to decode %s from cookie' % str)
      return {}
    end
    v
  end
end

