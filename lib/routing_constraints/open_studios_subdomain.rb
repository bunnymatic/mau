module RoutingConstraints
  class OpenStudiosSubdomain
    SUBDOMAIN = 'openstudios'.freeze

    def self.in_subdomain?(request)
      request.host.starts_with?(SUBDOMAIN)
    end

    def self.matches?(request)
      request.subdomain.present? && in_subdomain?(request)
    end
  end
end
