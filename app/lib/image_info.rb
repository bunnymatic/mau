class ImageInfo < Hashie::Mash

  def width
    self[:width].to_i
  end

  def height
    self[:height].to_i
  end

end
