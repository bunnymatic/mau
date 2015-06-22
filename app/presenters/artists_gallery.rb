class ArtistsGallery < ArtistsPresenter

  PER_PAGE = 20

  attr_reader :pagination, :per_page, :letter

  delegate :items, :has_more?, :current_page, :next_page, :to => :pagination

  def initialize(os_only, letter, current_page, per_page = PER_PAGE)
    super os_only
    @letter = letter.downcase
    @per_page = per_page
    @current_page = current_page.to_i
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
      artist.active? && artist.lastname.present? && artist.representative_piece && (letter == artist.lastname[0].downcase)
    end
  end


end
