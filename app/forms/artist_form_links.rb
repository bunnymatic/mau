class ArtistFormLinks
  #
  # As of Nov 2025
  # This is the distribution of links.
  #
  # {"website"=>637,
  #  "blog"=>122,
  #  "instagram"=>281,
  #  "facebook"=>300,
  #  "twitter"=>109,
  #  "pinterest"=>30,
  #  "flickr"=>46,
  #  "artspan"=>75,
  #  "myspace"=>10}
  #
  # Given this, with the introduction of this FormLinks module.
  # we'll be dropping support for pinterest, flickr and myspace
  #
  include ActiveModel::Model

  attr_accessor :artspan, :blog, :facebook, :instagram, :twitter, :website

  class Base
    class << self
      def force_https(url)
        parsed = URI.parse(url)
        parsed.scheme = 'https'
        parsed.to_s
      end

      def placeholder_link
        'https://my.website.example.com'
      end

      def handle_from_link(_link)
        nil
      end
    end
  end

  class InstagramFormatter < Base
    URL = 'https://www.instagram.com/'.freeze
    HANDLE_FINDER = /#{URL}(.*)/

    class << self
      def format(handle)
        return nil if handle.blank?
        return handle if handle.starts_with?(URL)
        if handle.starts_with? '@'
          return "#{URL}#{handle[1..]}"
        elsif handle.starts_with? %r{https?://}
          case handle
          when %r{^https?://www\.instagram\.com/}
            return force_https(handle)
          when %r{(.*\.)?instagram\.com/(.*)}
            return "#{URL}#{$2}"
          when %r{^https?://([^/\.]*$)}
            return "#{URL}#{$1}"
          else
            return nil
          end
        elsif handle =~ %r{.*instagram\.com/(.*)}
          return "#{URL}#{$1}"
        end

        "#{URL}#{handle}"
      end

      def handle_from_link(link)
        HANDLE_FINDER =~ link
        $1
      end

      def placeholder_link
        "#{URL}my-instagram-handle"
      end
    end
  end

  class FacebookFormatter < Base
    URL = 'https://www.facebook.com/'.freeze
    HANDLE_FINDER = /#{URL}(.*)/

    class << self
      def format(handle)
        return nil if handle.blank?
        return handle if handle.starts_with?(URL)
        if handle.starts_with? '@'
          return "#{URL}#{handle[1..]}"
        elsif handle.starts_with? %r{https?://}
          case handle
          when %r{^https?://www\.facebook\.com/}
            return force_https(handle)
          when %r{(.*\.)?facebook\.com/(.*)}
            return "#{URL}#{$2}"
          when %r{^https?://([^/\.]*$)}
            return "#{URL}#{$1}"
          else
            return nil
          end
        elsif handle =~ %r{.*facebook\.com/(.*)}
          return "#{URL}#{$1}"
        end

        "#{URL}#{handle}"
      end

      def handle_from_link(link)
        HANDLE_FINDER =~ link
        $1
      end

      def placeholder_link
        "#{URL}my-facebook-handle"
      end
    end
  end

  class TwitterFormatter < Base
    URL = 'https://x.com/'.freeze
    HANDLE_FINDER = /#{URL}(.*)/
    class << self
      def format(handle)
        return nil if handle.blank?
        return handle if handle.starts_with?(URL)
        if handle.starts_with? '@'
          return "#{URL}#{handle[1..]}"
        elsif handle.starts_with? %r{https?://}
          case handle
          when %r{^https?://(www.)?x.com/}
            return force_https(handle)
          when %r{^https?://.*twitter.com/(.*)}, %r{^https?://([^/\.]*$)}
            return "#{URL}#{$1}"
          else
            return nil
          end
        elsif handle =~ %r{(www.)?(x|twitter).com/(.*)}
          return "#{URL}#{$3}"
        end

        "#{URL}#{handle}"
      end

      def handle_from_link(link)
        HANDLE_FINDER =~ link
        $1
      end

      def placeholder_link
        "#{URL}my-x-handle"
      end
    end
  end

  class ArtspanFormatter < Base
    URL = 'https://www.artspan.org/art/'.freeze
    HANDLE_FINDER = /#{URL}(.*)/

    class << self
      def format(handle)
        return nil if handle.blank?
        return handle if handle.starts_with?(URL)
        if handle.starts_with? '@'
          return "#{URL}#{handle[1..]}"
        elsif handle.starts_with? %r{https?://}
          return case handle
                 when %r{^https?://www.artspan.org}
                   force_https(handle)
                 when %r{^https?://.*artspan.org/(.*)}, %r{^https?://([^/\.]*$)}
                   "#{URL}#{$1}"
                 end
        elsif handle =~ %r{artspan.org/(art/)?(.*)}
          return "#{URL}#{$2}"
        end

        "#{URL}#{handle}"
      end

      def handle_from_link(link)
        HANDLE_FINDER =~ link
        $1
      end

      def placeholder_link
        "#{URL}my-artspan-handle"
      end
    end
  end

  class WebsiteFormatter < Base
    class << self
      def format(handle)
        return nil unless handle

        parsed = URI.parse(handle)
        return nil if parsed.host.blank? || parsed.scheme.blank?

        parsed.to_s
      rescue URI::InvalidURIError
        nil
      end
    end
  end

  class << self
    def placeholder_link(source)
      handler = handler_class(source)
      handler&.placeholder_link
    end

    def link_from_handle(handle, source:)
      formatter = handler_class(source)

      formatter&.format(handle)
    end

    def handle_from_link(link, source:)
      formatter = handler_class(source)
      formatter&.handle_from_link(link)
    end

    private

    def handler_class(source)
      case source.to_sym
      when :artspan
        ArtspanFormatter
      when :facebook
        FacebookFormatter
      when :instagram
        InstagramFormatter
      when :twitter
        TwitterFormatter
      when :website, :blog
        WebsiteFormatter
      end
    end
  end

  include Enumerable

  def initialize(links)
    @links = links.to_h { |k, v| [k, self.class.link_from_handle(v, source: k)] }
  end

  def each(&)
    @links.each(&)
  end
end
