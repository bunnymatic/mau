class ArtistsGallery < ArtistsPresenter

  PER_PAGE = 20

  attr_reader :pagination, :per_page, :filters

  delegate :items, :has_more?, :current_page, :next_page, :to => :pagination

  def initialize(os_only, current_page, filter, per_page = PER_PAGE)
    super os_only
    @per_page = per_page
    @filters = (filter || '').downcase.strip.split(/\s+/).compact
    @pagination = ArtistsPagination.new(artists, current_page, @per_page)
  end

  def empty_message
    if os_only
      "Sorry, no one has signed up for the next Open Studios, yet.  Check back later."
    else
      "Sorry, we couldn't find any artists in the system."
    end
  end

  def artists
    super.select do |artist|
      keep = artist.representative_piece
      if filters.any?
        keep && begin
                  s = [artist.firstname, artist.lastname, artist.nomdeplume, artist.login].join
                  filters.any?{|f| s =~ /#{f}/i}
                end
      else
        keep
      end
    end
  end


end


