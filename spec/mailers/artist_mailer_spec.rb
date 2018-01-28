# frozen_string_literal: true

require 'rails_helper'

describe ArtistMailer do
  let(:artist) { FactoryBot.create(:artist, :active) }
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:pending_artist) { FactoryBot.create(:artist, :pending) }

  describe 'notification mail for a new signup' do
    before do
      @mail = ArtistMailer.signup_notification(pending_artist)
    end
    it 'includes an activation code' do
      expect(@mail.to_s).to match activate_url(activation_code: pending_artist.activation_code)
    end
  end

  describe 'new activated account' do
    let(:mail) { ArtistMailer.activation(artist) }

    it 'works' do
      expect(mail).to have_body_text 'Your account has been activated.'
    end

    it 'includes their name' do
      expect(mail).to have_body_text artist.get_name
    end

    it 'includes a welcome message' do
      expect(mail).to have_body_text 'YOUR MAU TODO LIST'
    end
  end

  describe 'resend activation mail' do
    before do
      @mail = ArtistMailer.resend_activation(pending_artist)
    end
    it 'includes an activation code' do
      expect(@mail).to have_body_text(activate_url(activation_code: pending_artist.activation_code))
    end
  end

  describe 'favorite notification' do
    let(:mail) { ArtistMailer.favorite_notification(artist, fan) }
    it 'includes a link to the artists page' do
      expect(mail).to have_body_text artist_url(artist)
    end
    it "includes the artist's name" do
      expect(mail).to have_body_text artist.get_name
    end
    it "includes the fan's name" do
      expect(mail).to have_body_text fan.get_name
    end
  end
end
