module TagsHelper
  def tags_to_s(tags)
    (tags.collect {|t| t.name }.uniq).join(", ")
  end

  def tags_from_s(tagstr)
    TagConverter.new(tagstr).convert
  end

  # input frequency is assumed to be already scaled between [0.0, 1.0]
  # def fontsize_from_frequency(freq)
  #   maximum = 24.0
  #   minimum = 8.0
  #   freq = freq.to_f
  #   f = [(maximum * (Math.cos(1.0-freq) ** 2)).round,minimum].max
  #   m = 4
  #   # return fontsize and margin
  #   [ "%dpx" % f, "%dpx" % m ]
  # end
end
