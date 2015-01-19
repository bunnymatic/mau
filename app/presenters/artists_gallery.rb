class ArtistsGallery < ArtistsPresenter

  PER_PAGE = 20

  attr_reader :pagination, :per_page, :filters

  delegate :items, :has_more?, :current_page, :next_page, :to => :pagination

  def initialize(view_context, os_only, current_page, filter, per_page = PER_PAGE)
    super view_context, os_only
    @per_page = per_page
    @filters = (filter || '').strip.split(/\s+/).compact
    @pagination = ArtistsPagination.new(@view_context, artists, current_page, @per_page)
  end

  def empty_message
    if os_only
      "Sorry, no one has signed up for the next Open Studios, yet.  Check back later."
    else
      "Sorry, we couldn't find any artists in the system."
    end
  end
  
  def alpha_links
    return @alpha_links if @alpha_links
    if num_artists > 0

      @alpha_links = (last_page + 1).times.map do |idx|
        firstidx = idx * per_page
        lastidx = [ firstidx + per_page, num_artists ].min - 1
        firstltr = artists[firstidx].lastname.capitalize[0..1]
        lastltr = artists[lastidx].lastname.capitalize[0..1]
        lnktxt = "%s - %s" % [firstltr, lastltr]
        [lnktxt, {:p => idx}, current_page == idx ]
      end
    end
    @alpha_links
  end

  private
  def artists
    @artists ||= super.select do |artist|
      keep = artist.representative_piece
      if filters.any?
        keep && begin
                  s = [artist.firstname, artist.lastname, artist.nomdeplume, artist.login].join
                  filters.any?{|f| s=~ /#{f}/}
                end
      else
        keep
      end
    end
    @artists
  end


end


