require_relative 'open_studios_subdomain'

module RoutingConstraints
  class AppSubdomain
    def self.matches?(request)
      request.subdomain.blank? || !RoutingConstraints::OpenStudiosSubdomain.in_subdomain?(request)
    end
  end
end
