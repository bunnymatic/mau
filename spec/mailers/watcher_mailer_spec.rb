require 'rails_helper'

describe WatcherMailer do
  let!(:watcher_email_list) { create(:watcher_email_list, :with_member) }

  describe '#notify_new_art_piece' do
    let(:to) { ['someone <someone@example.com>', 'other@example.com'] }
    let(:artist) { create(:artist, :with_art, :with_studio) }
    let(:art_piece) { artist.art_pieces.first }
    let(:studio) { artist.studio }

    subject(:mail) { described_class.notify_new_art_piece(art_piece, to) }

    let(:mail_body) do
      # sometimes when our matchers are at the attribute level, because of
      # utf8 encoding and such, matching against the raw mail body is more
      # dependable
      mail.html_part.body
    end

    context 'when there is an active open studios event' do
      let!(:open_studios) { create(:open_studios_event) }

      it 'sends it to the watchlist email list with the right subject' do
        expect(mail.to).to match_array ['someone@example.com', 'other@example.com']
        expect(mail.subject).to eq "[MAU Art][test] #{artist.get_name} just added some art"
      end

      it 'renders the email with the art piece, artist, studio and open studios info' do
        expect(mail).to have_body_text 'New Art:'
        expect(mail_body).to have_link(art_piece.title, href: art_piece_url(art_piece))
        expect(mail_body).to have_link(artist.get_name, href: artist_url(artist))
        expect(mail_body).to have_link(studio.name, href: studio_url(studio))
        expect(mail).to have_body_text("Participating in #{open_studios.for_display}: false")
      end

      it 'includes the picture' do
        expect(mail_body).to have_css("img[src='#{art_piece.attached_photo(:original)}'][title='#{art_piece.title}']")
      end

      it 'renders a little social media snippet' do
        tags = art_piece.tags.map { |tag| "##{tag.name}" }.join(' ')
        expect(mail).to have_body_text tags
      end
    end

    context 'if there is no current open studios event' do
      it 'renders the email with the art piece, artist, studio and open studios info' do
        expect(mail).to have_body_text 'New Art:'
        expect(mail_body).to have_link(art_piece.title, href: art_piece_url(art_piece))
        expect(mail_body).to have_link(artist.get_name, href: artist_url(artist))
        expect(mail_body).to have_link(studio.name, href: studio_url(studio))
        expect(mail).to_not have_body_text('Participating in')
      end
    end
  end
end
