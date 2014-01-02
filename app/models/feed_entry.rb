class FeedEntry

  DESCRIPTION_LENGTH = 600
  TITLE_LENGTH = 140
  DESC_CLEANER = Regexp.new(/<\/?[^>]*>/)

  delegate :date, :to => :entry

  attr_reader :entry, :truncate, :source, :clean_description

  def initialize(entry, source_url, clean_description = true, truncate = false)
    @entry = entry
    @source = source_url
    @truncate = truncate
    @clean_description = clean_description
  end

  def title
    @title ||=
      begin
        t = entry.title.strip || ''
        truncate ? t.truncate(TITLE_LENGTH) : t
      end
  end

  def description
    @desc ||=
      begin
        d = entry.description || ''
        if clean_description
          d.gsub!(DESC_CLEANER," ")
        end
        d.strip!
        (truncate && !(source.include? 'twitter')) ? d.truncate(DESCRIPTION_LENGTH) : d
      end
  end

end
