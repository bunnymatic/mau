class ArtistsGallery < ArtistsPresenter

  PER_PAGE = 28

  attr_reader :pagination, :per_page

  delegate :first_link, :previous_link, :items,
    :next_link, :last_link, :last_page, :first_page,
    :previous_page, :current_page, :next_page, :to => :pagination

  def initialize(view_context, os_only, current_page,  per_page = PER_PAGE)
    super view_context, os_only
    @per_page = per_page
    @pagination = ArtistsPagination.new(@view_context, artists, current_page, @per_page)
  end

  def artists
    @artists ||= super.select(&:representative_piece)
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

end


