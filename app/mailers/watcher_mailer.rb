class WatcherMailer < MauMailer
  def notify_new_art_piece(art_piece, to)
    @new_art = NewArtPiecePresenter.new(art_piece)

    from        = 'info@missionartists.org'
    reply_to    = NO_REPLY_FROM_ADDRESS
    subject     = "[MAU Art]#{environment_for_subject} #{@new_art.artist.get_name} just added some art"

    mail(to:, from:, reply_to:, subject:) do |fmt|
      fmt.html { render 'notify_new_art_piece' }
    end
  end
end
