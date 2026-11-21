require 'open-uri'
require 'vips'

###

# image1_url = artist.art_pieces.first.image_url
# background_url = background_template.url
# ImageProcessor.combine(image1_url, background_url)
module ImageProcessing
  class ImageProcessor
    class << self
      def combine_files(image1_url, image2_url, blend_mode: :over, offset: nil)
        offset ||= Offset.new(x: 0, y: 0)

        image1 = fetch_image(image1_url)
        image2 = fetch_image(image2_url)

        result = image1.composite2 image2, blend_mode, x: offset.x, y: offset.y
        composite_file = Tempfile.new(['comp', '.png'])
        result.write_to_file(composite_file.path)
        composite_file.path
      end

      def combine(image1, image2, blend_mode: :over, offset: nil)
        offset ||= Offset.new(x: 0, y: 0)

        image1.composite image2, blend_mode, x: offset.x, y: offset.y
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

        Image.new(::Vips::Image.new_from_file(dest.path))
      end

      def fetch_vips_image(uri)
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

        ::Vips::Image.new_from_file(dest.path)
      end
      # def get_image_size(uri)
      #   image = fetch_image(uri)
      #   { width: image.width, height: image.height }
      # end
    end
  end
end
