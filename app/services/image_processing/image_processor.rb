require 'open-uri'
require 'vips'

###

# image1_url = artist.art_pieces.first.image_url
# background_url = background_template.url
# ImageProcessor.combine(image1_url, background_url)
module ImageProcessing
  class ImageProcessor
    class << self
      def combine(image1_url, image2_url, blend_mode: :over, offset: nil)
        offset ||= Offset.new(x: 0, y: 0)

        file1 = fetch_image(image1_url)
        file2 = fetch_image(image2_url)

        image1 = ::Vips::Image.new_from_file(file1)
        image2 = ::Vips::Image.new_from_file(file2)

        result = image1.composite2 image2, blend_mode, x: offset.x, y: offset.y
        composite_file = Tempfile.new(['comp', '.png'])
        result.write_to_file(composite_file.path)
        composite_file.path
      end

      def fetch_image(uri)
        # branches for `open` are to avoid rubocop Security/Open violations
        source = begin
          path = URI.parse(uri)
          if path.respond_to? :open
            path.open
          else
            File.open(path, 'rb')
          end
        end
        dest = Tempfile.new
        dest.binmode
        dest.write(source.read)
        dest.close
        source.close

        dest.path
      end
    end
  end
end
