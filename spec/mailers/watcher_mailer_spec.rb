# frozen_string_literal: true

require 'rails_helper'

describe WatcherMailer do
  let!(:watcher_email_list) { create(:watcher_email_list, :with_member) }

  describe '#notify_new_art_piece' do
    let(:to) { ['someone <someone@example.com>', 'other@example.com'] }
    let(:artist) { create(:artist, :with_art, :with_studio) }
    let(:art_piece) { artist.art_pieces.first }
    let(:studio) { artist.studio }

    subject(:mail) { described_class.notify_new_art_piece(art_piece, to) }

    it 'sends it to the watchlist email list' do
      expect(mail.to).to match_array ['someone@example.com', 'other@example.com']
    end

    it 'renders the correct subject' do
      expect(mail.subject).to eq "[MAU Art][test] #{artist.get_name} just added some art"
    end

    it 'renders the email with the art piece, artist and studio info' do
      expect(mail).to have_body_text 'New Art:'
      expect(mail).to have_link(art_piece.title, href: art_piece_url(art_piece))
      expect(mail).to have_link(artist.get_name, href: artist_url(artist))
      expect(mail).to have_link(studio.name, href: studio_url(studio))
    end

    it 'includes the picture' do
      expect(mail).to have_css("img[src='#{art_piece.photo(:original)}'][title='#{art_piece.title}']")
    end

    it 'renders a little social media snippet' do
      tags = art_piece.tags.map { |tag| "##{tag.name}" }.join(' ')
      expect(mail).to have_body_text tags
    end
  end
end
