module TagsHelper
  def self.tags_to_s(tags)
    (tags.collect {|t| t.name }.uniq).join(", ")
  end

  def self.tags_from_s(tagstr)
    # split up tagstring into array of tags
    return [] unless tagstr.present?
    tagnames = tagstr.strip.split(',').each { |h| h.strip! }.uniq
    tags = []
    alltags = ArtPieceTag.all
    tag_lut = {}
    alltags.map do |t| 
      if t && t.name != nil && !t.name.empty?
        tag_lut[t.name.downcase] = t 
      end
    end
    tagnames.each do |tg|
      tag = tag_lut[tg.downcase]
      if !tag 
        tag = ArtPieceTag.new
        tag.name = tg
        tag.save
      end
      tags << tag
    end
    tags
  end
  
  def self.fontsize_from_frequency(freq)
    """ input frequency is assumed to be already scaled between [0.0, 1.0] """
    freq = freq.to_f
    f = [(24.0 * (Math.cos(1.0-freq) ** 2)).round,8.0].max
    #m = [(15.0 * (Math.cos(1.0-freq) ** 2)).round,6.0].max
    m = 4
    # return fontsize and margin
    result = [ "%dpx" % f, "%dpx" % m ]
    result
  end
end
