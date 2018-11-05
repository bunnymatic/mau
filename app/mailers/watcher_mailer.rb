# frozen_string_literal: true

class WatcherMailer < MauMailer
  def notify_new_art_piece(art_piece, to)
    @new_art = NewArtPiecePresenter.new(art_piece)

    from        = 'info@missionartists.org'
    reply_to    = 'noreply@missionartists.org'
    subject     = "[MAU Art]#{environment_for_subject} #{@new_art.artist.get_name} just added some art"

    mail(to: to, from: from, reply_to: reply_to, subject: subject) do |fmt|
      fmt.html { render 'notify_new_art_piece' }
    end
  end
end
