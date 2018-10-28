# frozen_string_literal: true

require 'rails_helper'

describe NewArtPiecePresenter do
  let(:os_start_date) { Time.current }
  let!(:open_studios_event) { create(:open_studios_event, start_date: os_start_date) }
  let(:artist) { create(:artist, :active, :with_studio) }
  let(:art_piece) do
    create(:art_piece, :with_tags, artist: artist)
  end
  subject(:presenter) { described_class.new(art_piece) }

  describe '#open_studios_info' do
    its(:open_studios_info) { is_expected.to be_nil }

    context 'artist is doing open studios' do
      before do
        Timecop.freeze(Time.zone.parse('2017-03-01'))
      end
      let(:os_start_date) { Time.zone.parse('2017-05-01') }

      context 'and they are in a studio' do
        let(:artist) { create(:artist, :active, :with_studio, doing_open_studios: open_studios_event) }
        it 'shows a see more message' do
          expect(presenter.open_studios_info).to include "See more at #{artist.studio.name} during Open Studios"
        end
      end

      context 'and they are in an indy studio' do
        let(:artist) { create(:artist, :active, doing_open_studios: open_studios_event) }
        it 'shows a see more message' do
          expect(presenter.open_studios_info).to include "See more at #{artist.address} during Open Studios"
        end
      end
    end
  end

  describe '#hash_tags' do
    its(:hash_tags) { is_expected.to include '@missionartists' }
    its(:hash_tags) { is_expected.to include "##{art_piece.tags.first.name}" }
    its(:hash_tags) { is_expected.to include "##{art_piece.medium.name}" }
    it 'does not include any os tags' do
      os_tags = [
        '#SFOS',
        "#SFOS#{open_studios_event.start_date.year}",
        '#SFopenstudios',
        '#missionopenstudios',
        '#springopenstudios'
      ]
      expect(os_tags.none? { |tag| presenter.hash_tags.include?(tag) }).to eq true
    end

    context 'when the art piece tags have a leading #' do
      before do
        art_piece.tags.create(name: '#1890Bryant')
      end
      it 'does not show ## for those tags' do
        expect(presenter.hash_tags).to include '#1890Bryant'
        expect(presenter.hash_tags).not_to include '##1890Bryant'
      end
    end

    context 'artist is doing open studios' do
      let(:artist) { create(:artist, :active, :with_studio, doing_open_studios: open_studios_event) }
      context 'in the spring (before june)' do
        before do
          Timecop.freeze(Time.zone.parse('2017-03-01'))
        end
        let(:os_start_date) { Time.zone.parse('2017-05-01') }
        it 'shows spring open studios tags' do
          os_tags = ['#missionopenstudios',
                     '#springopenstudios']
          expect(os_tags.all? { |tag| presenter.hash_tags.include?(tag) }).to eq true
        end
      end
      context 'in the spring (before june)' do
        before do
          Timecop.freeze(Time.zone.parse('2017-07-01'))
        end
        let(:os_start_date) { Time.zone.parse('2017-11-01') }
        it 'shows fall open studios tags' do
          os_tags = [
            '#SFOS',
            "#SFOS#{open_studios_event.start_date.year}",
            '#SFopenstudios'
          ]
          expect(os_tags.all? { |tag| presenter.hash_tags.include?(tag) }).to eq true
        end
      end

      context 'is past the current open studios' do
        before do
          Timecop.freeze(Time.zone.parse('2017-12-01'))
        end
        let(:os_start_date) { Time.zone.parse('2017-11-01') }
        it 'does not include any os tags' do
          os_tags = [
            '#SFOS',
            "#SFOS#{open_studios_event.start_date.year}",
            '#SFopenstudios',
            '#missionopenstudios',
            '#springopenstudios'
          ]
          expect(os_tags.none? { |tag| presenter.hash_tags.include?(tag) }).to eq true
        end
      end
    end
  end
end
