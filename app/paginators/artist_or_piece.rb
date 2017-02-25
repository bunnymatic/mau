# frozen_string_literal: true
module ArtistOrPiece
  def page_args
    @mode_string ? { m: @mode_string } : {}
  end

  def by_artists?
    (@mode_string != 'p')
  end

  def by_pieces?
    (@mode_string == 'p')
  end
end
