module ImageProcessing
  # class InstagramCardTemplate
  #   def self.latest
  #     # return template url
  #   end
  # end

  # class PostcardTemplate
  #   def self.latest
  #     # return template url
  #   end
  # end

  # class InstagramCardBuilder

  #   def self.build(art_piece)
  #     template = InstagramCardTemplate.latest
  #     BaseCardBuilder.build(art_piece, template)
  #   end
  # end

  # class PostcardBuilder

  #   def self.build(art_piece)
  #     template = PostcardTemplate.latest
  #     BaseCardBuilder.build(art_piece, template)
  #   end
  # end

  class BaseCardBuilder
    class << self
      def build(art_piece, template_url)
        new(art_piece, template_url).build
      end
    end

    def initialize(art_piece, template_url)
      @art_piece = art_piece
      @template_url = template_url
    end

    def build
      # We need to grab the image url
      # We need to grab the template url
      #      template_url = template_url

      # # get image sizes
      art_piece_dimensions = art_piece_image.dimensions
      template_dimensions = template_image.dimensions
      puts art_piece_dimensions, 'ART PIECE==='
      puts template_dimensions, 'TEMPLATE====='

      if art_piece_image.orientation == :portrait and template_image.orientation == :landscape
        # resize/scale by HEIGHT and CENTER by width
        # height of template / height of arpiece
        scale_factor = template_image.height.to_f / art_piece_image.height.to_f
        resized_image = art_piece_image.resize(scale_factor)
        puts scale_factor, 'SCALE FACTOR'
        puts resized_image, 'RESIZED IMAGE'
        offset_x = (template_image.width - resized_image.width) / 2
        offset = Offset.new(x: offset_x, y: 0)
        puts offset
        interim = ImageProcessing::ImageProcessor.combine(background_image, resized_image, offset:)

        combined_image = ImageProcessing::ImageProcessor.combine(interim, template_image) # , offset: offset)
        composite_file = Tempfile.new(['comp', '.png'])
        combined_image.write_to_file(composite_file.path)
        composite_file.path
      else
        # resiz/cale by WIDTH and CENTER by height
        scale_factor = template_image.width.to_f / art_piece_image.width.to_f
        resized_image = art_piece_image.resize(scale_factor)
        puts scale_factor, 'SCALE FACTOR'
        puts resized_image, 'RESIZED IMAGE'
        offset_y = (template_image.height - resized_image.height) / 2
        offset = Offset.new(x: 0, y: offset_y)
        puts offset
        interim = ImageProcessing::ImageProcessor.combine(background_image, resized_image, offset:)

        combined_image = ImageProcessing::ImageProcessor.combine(interim, template_image) # , offset: offset)
        composite_file = Tempfile.new(['comp', '.png'])
        combined_image.write_to_file(composite_file.path)
        composite_file.path
      end
      # resize art_piece to fit on template
      # compute offset
      # run combine
    end

    private

    def background_image
      Image.new(::Vips::Image.black(template_image.width, template_image.height) + 255)
    end

    def art_piece_url
      @art_piece.image(:original)
    end

    def art_piece_image
      @art_piece_image ||= ImageProcessing::ImageProcessor.fetch_image(art_piece_url)
    end

    def template_image
      @template_image ||= ImageProcessing::ImageProcessor.fetch_image(@template_url)
    end
  end
end
