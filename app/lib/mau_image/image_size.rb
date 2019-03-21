# frozen_string_literal: true

module MauImage
  class ImageSize
    attr_reader :name, :width, :height, :prefix

    SIZES = {
      thumb: [100, 100, 't_'],
      #:cropped_thumb => [127, 127, 'ct_'],
      small: [200, 200, 's_'],
      medium: [400, 400, 'm_'],
      large: [800, 800, 'l_'],
      original: [nil, nil, ''],
    }.freeze

    def initialize(name, width, height, prefix)
      @name = name.to_s
      @width = width
      @height = height
      @prefix = prefix
    end

    def self.all
      {}.tap do |sizes|
        SIZES.each { |k, v| sizes[k] = ImageSize.new(*([k] + v).flatten) }
      end
    end

    def self.find(key_or_size)
      k = keymap(key_or_size)
      all[k]
    end

    def self.allowed_sizes
      all.keys
    end

    class << self
      private

      def keymap(size)
        return :medium if size.blank?
        return size.to_sym if allowed_sizes.include? size.to_sym

        case size.to_s
        when 'orig'
          :original
        when 'sm', 's'
          :small
        when 'thumbnail'
          :thumb
        when 'med', 'm', 'standard', 'std'
          :medium
        when 'l'
          :large
        else
          :medium
        end
      end
    end
  end
end
