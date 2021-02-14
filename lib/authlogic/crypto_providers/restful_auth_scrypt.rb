require 'scrypt'

module Authlogic
  module CryptoProviders
    class RestfulAuthSCrypt < Authlogic::CryptoProviders::SCrypt
      # send in tokens as if it were restful auth
      # this is used only once as a smooth transition.  After this happens
      # because of `transition_from_crypto_providers` we'll write a new
      # password with the new scheme and this should never hit again
      def self.matches?(hash, *tokens)
        super(hash, *[REST_AUTH_SITE_KEY, tokens.reverse.flatten, REST_AUTH_SITE_KEY].flatten.compact)
      end
    end
  end
end
