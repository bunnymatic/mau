module TagsHelper
  def self.tags_to_s(tags)
    (tags.collect {|t| t.name }).join(", ")
  end

  def self.tags_from_s(tagstr)
    # split up tagstring into array of tags
    tagnames = tagstr.strip.split(',').each { |h| h.strip! }
    tags = []
    alltags = Tag.all
    tag_lut = {}
    alltags.map { |t| tag_lut[t.name] = t }
    tagnames.each do |tg|
      next if tg.empty?
      tag = tag_lut[tg]
      if !tag 
        tag = Tag.new
        tag.name = tg
        tag.save
      end
      tags << tag
    end
    tags
  end
  
  def self.fontsize_from_frequency(freq)
    freq = freq.to_f
    sinc = Math.sin(freq)/freq
    f = [24.0 * (Math.sin(1.6*freq) ** 2).round,7.0].max
    m = [15.0 * (Math.sin(1.6*freq) ** 2).round,7.0].max
    # return fontsize and margin
    [ "%dpx" % f, "%dpx" % m ]
  end
end
