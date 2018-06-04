# frozen_string_literal: true

require 'rails_helper'

describe WatcherMailer do
  let!(:watcher_email_list) { create(:watcher_email_list, :with_member) }

  describe '#notify_new_art_piece' do
    let(:art_piece) { create(:art_piece, :with_tags) }

    subject(:mail) { described_class.notify_new_art_piece(art_piece) }

    it 'sends it to the watchlist email list' do
      expect(mail.to).to eq WatcherMailerList.first.emails.map(&:email)
    end

    it 'renders the email with the art piece, artist and studio info' do
      expect(mail).to have_content "New Art: #{art_piece.title}"
    end

    it 'renders a little social media snippet' do
      tags = art_piece.tags.map { |tag| "##{tag.name}" }.join(' ')
      expect(mail).to have_content tags
    end
  end
end
