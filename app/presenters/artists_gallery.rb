class ArtistsGallery < ArtistsPresenter

  PER_PAGE = 20

  attr_reader :pagination, :per_page, :filters

  delegate :items, :has_more?, :current_page, :next_page, :to => :pagination

  attr_reader :filters, :letter

  def initialize(os_only, letter, current_page, filter, per_page = PER_PAGE)
    super os_only
    @letter = letter.downcase
    @per_page = per_page
    @filters = (filter || '').downcase.strip.split(/\s+/).compact
    @current_page = current_page
    @pagination = ArtistsPagination.new(artists, @current_page, @per_page)
  end

  def self.lastname_letters
    ArtPiece.joins(:artist).where(users:{state: 'active'}).group('lcase(left(users.lastname,1))').count.keys
  end

  def empty_message
    if os_only
      "Sorry, no one with that last name has signed up for the next Open Studios.  Check back later."
    else
      "Sorry, we couldn't find any artists with that last name in the system."
    end
  end

  def artists
    super.select do |artist|
      keep = artist.representative_piece && (letter == artist.lastname[0].downcase)
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
