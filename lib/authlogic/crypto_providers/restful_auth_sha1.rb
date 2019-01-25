# frozen_string_literal: true

require 'digest/sha1'

module Authlogic
  module CryptoProviders
    class RestfulAuthSha1 < Authlogic::CryptoProviders::Sha1
      # send in tokens as if it were restful auth
      # this is used only once as a smooth transition.  After this happens
      # because of `transition_from_crypto_providers` we'll write a new
      # password with the new scheme and this should never hit again
      def self.matches?(crypted, *tokens)
        super(crypted, *[REST_AUTH_SITE_KEY, tokens.reverse.flatten, REST_AUTH_SITE_KEY].flatten.compact)
      end
    end
  end
end
