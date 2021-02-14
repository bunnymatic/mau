require 'pathname'

class ImageFile
  include ImageFileHelpers

  def self.get_path(dir, size, fname)
    return '' if fname.empty?

    prefix = MauImage::ImageSize.find(size).prefix
    File.join(dir, prefix + fname)
  end

  def image_paths(image_info)
    file_match = Regexp.new("#{destfile}$")
    %i[large medium small thumb].index_with do |sz|
      image_info.path.gsub(file_match, MauImage::ImageSize.find(sz).prefix + destfile)
    end
  end
end
