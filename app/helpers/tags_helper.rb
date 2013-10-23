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

  # input frequency is assumed to be already scaled between [0.0, 1.0]
  def self.fontsize_from_frequency(freq)
    maximum = 24.0
    minimum = 8.0
    freq = freq.to_f
    f = [(maximum * (Math.cos(1.0-freq) ** 2)).round,minimum].max
    m = 4
    # return fontsize and margin
    [ "%dpx" % f, "%dpx" % m ]
  end
end
