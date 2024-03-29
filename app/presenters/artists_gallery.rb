class ArtistsGallery < ArtistsPresenter
  include Rails.application.routes.url_helpers

  ELLIPSIS = '&hellip;'.freeze
  LETTERS_REGEX = /[a-zA-Z]/
  attr_reader :pagination, :per_page, :letter, :ordering

  delegate :items, :more?, :current_page, :next_page, to: :pagination

  def initialize(os_only: false, letter: nil, ordering: nil, current_page: 0, per_page: Conf.pagination['artists']['per_page'])
    super(os_only:)
    @letter = letter.try(:downcase)
    @ordering = %i[lastname firstname].include?(ordering.try(:to_sym)) ? ordering.to_sym : :lastname
    @per_page = per_page
    @current_page = current_page.to_i
    @pagination = ArtistsPagination.new(artists, @current_page, @per_page)
  end

  def ordered_by_lastname?
    @ordering == :lastname
  end

  def self.letters(first_or_last)
    name = first_or_last.to_sym if %i[lastname firstname].include? first_or_last.to_sym
    return [] unless name

    letters = ArtPiece.joins(:artist).where(users: { state: Constants::User::STATE_ACTIVE }).group("lcase(left(users.#{name},1))").count.keys

    lettered_entries = letters.grep(LETTERS_REGEX).sort
    if letters.count > lettered_entries.count
      lettered_entries + [ELLIPSIS]
    else
      lettered_entries
    end
  end

  def path_to(desired_params, current_params)
    params = current_params.permit(:s, :l, :o).merge(desired_params)
    artists_path(sanitize_index_params(params))
  end

  def sanitize_index_params(params)
    params[:o] = (params[:o].presence.to_s == 'true')
    params[:s] = params[:s].presence.to_s == 'firstname' ? :firstname : :lastname
    params
  end

  def empty_message
    if os_only
      'Sorry, no one with that name has signed up for the next Open Studios.  Check back later.'
    else
      "Sorry, we couldn't find any artists with that name in the system."
    end
  end

  def artists
    super.select do |artist|
      keep = artist.active? && artist.representative_piece
      if keep
        name = artist.send(@ordering)
        keep && letter_match(letter, name)
      else
        false
      end
    end
  end

  def letter_match(lettr, name)
    return true if lettr.nil?

    first_letter = name[0].try(:downcase)
    (lettr == first_letter) || ((LETTERS_REGEX !~ first_letter) && lettr == ELLIPSIS)
  end
end
