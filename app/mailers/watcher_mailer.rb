# frozen_string_literal: true

class WatcherMailer < MauMailer
  def notify_new_art_piece(art_piece)
    from        = 'info@missionartists.org'
    reply_to    = 'noreply@missionartists.org'
    subject     = '[MAU Art] new art has been added'

    @art_piece = art_piece
    @artist = @art_piece.artist
    @studio = @artist.studio || IndependentStudio.new

    mail(to: WatcherMailerList.first.formatted_emails, from: from, reply_to: reply_to, subject: subject) do |fmt|
      fmt.html { render 'notify_new_art_piece' }
    end
  end
end
