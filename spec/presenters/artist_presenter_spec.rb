require 'rails_helper'

describe ArtistPresenter do
  include PresenterSpecHelpers

  let(:viewer) { FactoryBot.build(:artist, :active) }
  let(:artist) { FactoryBot.create(:artist, :active, :with_art, :with_studio) }
  subject(:presenter) { ArtistPresenter.new(artist) }

  context 'when the subject is an artist' do
    it 'delegates a bunch of stuff' do
      expect(artist).to be_valid
      expect(presenter.artist?).to be_truthy
      expect(presenter.in_the_mission?).to eq artist.in_the_mission?
      expect(presenter.media?).to be_truthy
      expect(presenter.bio?).to be_truthy
      expect(presenter.bio_html).to eq RDiscount.new(artist.artist_info.bio).to_html.html_safe
      expect(presenter.links?).to be_truthy
      expect(presenter.links).to be_present
      expect(presenter.favorites_count).to be_nil
      expect(presenter.studio_name).to eql artist.studio.name
      expect(presenter.art?).to eql true
      expect(presenter.show_url).to match %r{/artists/#{artist.login}$}
      expect(presenter.current_open_studios_participant).to eq artist.current_open_studios_participant
    end

    context '#phone_for_display' do
      it 'returns a formatted phone number' do
        artist.phone = '1234567777'
        expect(presenter.phone_for_display).to eq '123-456-7777'
      end
    end

    it 'has a good map div for google maps' do
      map_info = subject.map_info
      html = Capybara::Node::Simple.new(map_info)
      expect(html).to have_selector('.map__info-window-art')
    end

    context 'when we wrap a nil artist' do
      let(:artist) { nil }
      it { is_expected.to_not be_valid }
    end

    context 'without studio' do
      let(:artist) { FactoryBot.create(:artist, :active, :with_art) }
      it 'has a good map div for google maps' do
        map_info = subject.map_info
        html = Capybara::Node::Simple.new(map_info)
        expect(html).to have_css('.map__info-window-art')
      end
    end

    context 'without media' do
      before do
        allow_any_instance_of(ArtPiece).to receive(:medium).and_return(nil)
      end

      it "#media? returns false and primary medium is ''" do
        expect(presenter.media?).to eql false
        expect(presenter.primary_medium).to eql ''
      end
    end

    context 'without bio' do
      before do
        allow(artist).to receive_message_chain(:artist_info, :bio).and_return(nil)
      end

      describe '#bio?' do
        it { expect(presenter.bio?).to eq false }
      end
    end

    context 'without links' do
      before do
        artist.update({ links: {} })
      end

      describe '#links?' do
        its(:links?) { is_expected.to eq false }
      end
    end

    context 'without art' do
      let(:artist) { FactoryBot.create(:artist, :active) }

      it '#art_pieces and art? should return' do
        expect(presenter.art_pieces).to be_empty
        expect(presenter.art?).to be_falsy
      end
    end
  end

  context 'when the subject is a fan' do
    let(:artist) { FactoryBot.build(:mau_fan, :active) }
    describe 'artist?' do
      its(:artist?) { is_expected.to eq false }
    end
  end

  describe '#last_updated_at' do
    let(:artist) { FactoryBot.create(:artist, :active, updated_at: 2.days.ago) }
    before do
      freeze_time
    end

    it 'returns artist.updated_at if no open studios' do
      expect(presenter.last_updated_at).to eq 2.days.ago
    end

    context 'the artist is doing open studios' do
      before do
        os = create(:open_studios_event)
        artist.open_studios_events << os
        info = artist.current_open_studios_participant
        info.updated_at = 5.days.ago
        info.save!
      end

      context 'they updated their artist more recently' do
        it 'returns the artist updated at' do
          expect(presenter.last_updated_at).to eq 2.days.ago
        end
      end

      context 'they updated their os info more recently' do
        before do
          info = artist.current_open_studios_participant
          info.updated_at = 1.day.ago
          info.save!
        end
        it 'returns the os info updated at' do
          expect(presenter.last_updated_at).to eq 1.day.ago
        end
      end
    end
  end
end
