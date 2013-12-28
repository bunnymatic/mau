class ArtistGalleryPresenter

  PER_PAGE = 28

  attr_accessor :pagination, :artists

  delegate :items, :first_link, :previous_link, :next_link, :last_link, :last_page, :first_page, :previous_page, :current_page, :next_page, :to => :pagination

  def initialize(view_context, artists, current_page, per_page = PER_PAGE)
    @view_context = view_context
    @artists = artists.select(&:representative_piece)
    @per_page = per_page
    @pagination = ArtistsPagination.new(@view_context, @artists, current_page, @per_page)
  end

  def alpha_links
    return @alpha_links if @alpha_links
    if @artists.length > 0
      cur_page = current_page
      num_artists = artists.length

      @alpha_links = (last_page + 1).times.map do |idx|
        firstidx = idx * @per_page
        lastidx = [ firstidx + @per_page, num_artists ].min - 1
        firstltr = artists[firstidx].lastname.capitalize[0..1]
        lastltr = artists[lastidx].lastname.capitalize[0..1]
        lnktxt = "%s - %s" % [firstltr, lastltr]
        [lnktxt, {:p => idx}, current_page == idx ]
      end
    end
    @alpha_links
  end

end
