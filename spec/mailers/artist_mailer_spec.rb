# frozen_string_literal: true

require 'rails_helper'

describe ArtistMailer, elasticsearch: :stub do
  let(:artist) { FactoryBot.create(:artist, :active) }
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:pending_artist) { FactoryBot.build(:artist, :pending) }

  describe '#signup_notification' do
    subject(:mail) { ArtistMailer.signup_notification(pending_artist) }
    it 'includes the todo list' do
      expect(mail).to have_body_text('Once you\'ve activated you should:')
    end
    it 'includes a register for os link' do
      expect(mail).to have_link('register for open studios', href: register_open_studios_url)
    end
  end

  describe '#activation' do
    subject(:mail) { ArtistMailer.activation(artist) }

    it 'works' do
      expect(mail).to have_body_text 'Your account has been activated.'
    end

    it 'includes their name' do
      expect(mail).to have_body_text artist.get_name
    end

    it 'includes a welcome message' do
      expect(mail).to have_body_text 'TODO LIST'
    end
    it 'includes a register for os link' do
      expect(mail).to have_link('register for open studios', href: register_open_studios_url)
    end
  end

  describe '#resend_activation' do
    subject(:mail) { ArtistMailer.resend_activation(pending_artist) }
    it 'includes an activation code' do
      expect(mail).to have_link_in_body(activate_url(activation_code: pending_artist.activation_code))
    end
  end

  describe '#favorite_notification' do
    subject(:mail) { ArtistMailer.favorite_notification(artist, fan) }
    it 'includes a link to the artists page' do
      expect(mail).to have_link_in_body artist_url(artist)
    end
    it "includes the artist's name" do
      expect(mail).to have_body_text artist.get_name
    end
    it "includes the fan's name" do
      expect(mail).to have_body_text fan.get_name
    end
  end

  describe '#welcome_to_open_studios' do
    let(:open_studios) { build(:open_studios_event) }
    subject(:mail) { ArtistMailer.welcome_to_open_studios(artist, open_studios) }
    it 'includes a link to the artists profile page' do
      expect(mail).to have_link_in_body 'upload new images of your artwork', href: manage_art_artist_url(artist)
    end
    it 'includes a link to the donate button on the artists profile page' do
      expect(mail).to have_link_in_body 'going to the site', href: edit_artist_url(artist, anchor: 'events')
    end
    it "includes links to mau's social media sites" do
      expect(mail).to have_link_in_body 'Facebook', href: Conf.social_links['facebook']
      expect(mail).to have_link_in_body 'Twitter', href: Conf.social_links['twitter']
      expect(mail).to have_link_in_body 'Instagram', href: Conf.social_links['instagram']
    end
    it "includes the artist's name" do
      expect(mail).to have_body_text artist.get_name
    end
    it 'includes the Open Studios date' do
      expect(mail).to have_body_text open_studios.for_display(reverse: true)
    end
  end
end
