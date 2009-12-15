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
    delta = ( 2 * Math.log(freq+1) ).round
    # return fontsize and margin
    [ "%dpx" % (9 + 2*delta), "%dpx" % (3*delta) ]
  end
end
