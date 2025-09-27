class MediaService
  include TagMediaMixin

  def self.media_sorted_by_frequency
    Medium
      .joins(:art_pieces)
      .select('media.*', 'count(*) frequency')
      .group('id')
      .order(frequency: :desc)
  end

  def self.most_popular_medium
    media_sorted_by_frequency.first
  end
end
