# frozen_string_literal: true

require 'pathname'

class ImageFile
  include ImageFileHelpers

  def self.get_path(dir, size, fname)
    return '' if fname.empty?
    prefix = MauImage::ImageSize.find(size).prefix
    # idx = fname.hash % @@IMG_SERVERS.length
    # svr = @@IMG_SERVERS[idx]
    File.join(dir, prefix + fname)
  end

  def image_paths(image_info)
    file_match = Regexp.new(destfile + '$')
    Hash[%i[large medium small thumb].map do |sz|
           [sz, image_info.path.gsub(file_match, MauImage::ImageSize.find(sz).prefix + destfile)]
         end]
  end
end
