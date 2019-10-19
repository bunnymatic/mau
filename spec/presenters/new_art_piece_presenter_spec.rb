# frozen_string_literal: true

require 'rails_helper'

describe NewArtPiecePresenter do
  let(:os_end_date) { Time.current - 1.day }
  let!(:open_studios_event) do
    create(:open_studios_event,
           start_date: os_end_date - 1.day,
           end_date: os_end_date)
  end
  let(:artist) { create(:artist, :active, :with_studio) }
  let(:medium) { create(:medium, name: 'My Medium') }
  let(:art_piece) do
    create(:art_piece, :with_tags, artist: artist, medium: medium)
  end
  subject(:presenter) { described_class.new(art_piece) }

  describe '#open_studios_info' do
    its(:open_studios_info) { is_expected.to be_nil }

    context 'artist is doing open studios' do
      let(:artist) { create(:artist, :active, :with_studio, doing_open_studios: open_studios_event) }
      context 'and it is during spring open studios' do
        before do
          Timecop.freeze(Time.zone.parse('2017-03-01 17:00:00'))
        end
        let(:os_end_date) { Time.zone.parse('2017-03-01') }
        its(:open_studios_info) { is_expected.to_not be_nil }
      end
      context 'and it is before spring  open studios' do
        before do
          Timecop.freeze(Time.zone.parse('2017-03-01'))
        end
        let(:os_end_date) { Time.zone.parse('2017-05-01') }

        it 'shows a see more message' do
          expect(presenter.open_studios_info).to include "See more at #{artist.studio.name} during Open Studios"
        end

        context 'and they are in an indy studio' do
          before do
            artist.update(studio: nil)
          end
          it 'shows a see more message' do
            expect(presenter.open_studios_info).to include "See more at #{artist.address} during Open Studios"
          end
        end
      end
    end
  end

  describe '#hash_tags' do
    its(:hash_tags) { is_expected.to include '@missionartists' }
    its(:hash_tags) { is_expected.to include "##{art_piece.tags.first.name.gsub(/[\s-]/, '')}" }
    its(:hash_tags) { is_expected.to include '#mymedium' }
    its(:hash_tags) { is_expected.to include '#sfart' }
    it 'does not include any os tags' do
      os_tags = [
        '#SFOS',
        "#SFOS#{open_studios_event.start_date.year}",
        '#SFopenstudios',
        '#missionopenstudios',
        '#springopenstudios',
      ]
      expect(os_tags.none? { |tag| presenter.hash_tags.include?(tag) }).to eq true
    end

    context 'when there is no medium' do
      let(:medium) { nil }
      it 'does not blow up' do
        expect(presenter.hash_tags).to be_present
      end
    end

    context 'when the art piece tags have a leading #' do
      before do
        art_piece.tags.create(name: '#1890Bryant')
      end
      it 'does not show ## for those tags' do
        expect(presenter.hash_tags).to include '#1890bryant'
        expect(presenter.hash_tags).not_to include '##1890bryant'
      end
    end

    context 'artist is doing open studios' do
      let(:artist) { create(:artist, :active, :with_studio, doing_open_studios: open_studios_event) }
      context 'in the spring (before june)' do
        before do
          Timecop.freeze(Time.zone.parse('2017-03-01'))
        end
        let(:os_end_date) { Time.zone.parse('2017-05-01') }
        it 'shows spring open studios tags' do
          os_tags = ['#missionopenstudios',
                     '#springopenstudios']
          expect(os_tags.all? { |tag| presenter.hash_tags.include?(tag) }).to eq true
        end
      end
      context 'in the fall (before june)' do
        before do
          Timecop.freeze(Time.zone.parse('2017-07-01'))
        end
        let(:os_end_date) { Time.zone.parse('2017-11-01') }
        it 'shows fall open studios tags' do
          os_tags = [
            '#SFOS',
            "#SFOS#{open_studios_event.start_date.year}",
            '#SFopenstudios',
          ]
          expect(os_tags.all? { |tag| presenter.hash_tags.include?(tag) }).to eq true
        end
      end

      context 'is past the current open studios' do
        before do
          Timecop.freeze(Time.zone.parse('2017-12-01'))
        end
        let(:os_end_date) { Time.zone.parse('2017-11-01') }
        it 'does not include any os tags' do
          os_tags = [
            '#SFOS',
            "#SFOS#{open_studios_event.start_date.year}",
            '#SFopenstudios',
            '#missionopenstudios',
            '#springopenstudios',
          ]
          expect(os_tags.none? { |tag| presenter.hash_tags.include?(tag) }).to eq true
        end
      end
    end
  end
end
