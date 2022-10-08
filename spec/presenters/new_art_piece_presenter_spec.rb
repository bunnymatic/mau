require 'rails_helper'

describe NewArtPiecePresenter do
  let(:os_end_date) { 1.day.ago }
  let(:promoted) { true }
  let!(:open_studios_event) do
    create(:open_studios_event,
           start_date: os_end_date - 1.day,
           end_date: os_end_date,
           promote: promoted)
  end
  let(:artist) { create(:artist, :active, :with_studio) }
  let(:medium) { create(:medium, name: 'My Medium') }
  let(:art_piece) do
    create(:art_piece, :with_tags, artist: artist, medium: medium)
  end
  let(:current_time) {}

  subject(:presenter) { described_class.new(art_piece) }

  before do
    travel_to(current_time ? Time.zone.parse(current_time) : Time.current)
  end

  describe '#open_studios_info' do
    its(:open_studios_info) { is_expected.to be_nil }

    context 'artist is doing open studios' do
      let(:artist) { create(:artist, :active, :with_studio, doing_open_studios: open_studios_event) }

      context 'and it is during spring open studios' do
        let(:current_time) { '2017-03-01 17:00:00' }
        let(:os_end_date) { Time.zone.parse('2017-03-01') }
        its(:open_studios_info) { is_expected.to_not be_nil }
      end

      context 'and it is before spring  open studios' do
        let(:current_time) { '2017-03-01' }
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

      context 'and it is during spring open studios but os is not promoted' do
        let(:current_time) { '2017-03-01 17:00:00' }
        let(:promoted) { false }
        its(:open_studios_info) { is_expected.to be_nil }
      end
    end
  end

  describe '#hash_tags' do
    before do
      SitePreferences.instance.update(social_media_tags: '#whatever-man    another, #this-tag, #final-tag')
    end
    it 'includes tags from the art' do
      expect(subject.hash_tags).to include "##{art_piece.tags.first.name.gsub(/[\s-]/, '')}"
    end
    it 'includes tags from the art medium' do
      expect(subject.hash_tags).to include '#mymedium'
    end
    it 'includes base tags' do
      expect(subject.hash_tags).to include '#missionartists #sfart'
    end
    it 'includes custom tags' do
      expect(subject.hash_tags).to start_with('#whateverman #another #thistag #finaltag')
    end
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
        let(:current_time) { '2017-03-01' }
        let(:os_end_date) { Time.zone.parse('2017-05-01') }
        it 'shows spring open studios tags' do
          os_tags = [
            '#missionopenstudios',
            '#springopenstudios',
          ]
          expect(os_tags.all? { |tag| presenter.hash_tags.include?(tag) }).to eq true
        end
      end

      context 'in the fall (before june)' do
        let(:current_time) { '2017-07-01' }
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
        let(:current_time) { '2017-12-01' }
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

      context 'and os is not promoted' do
        let(:current_time) { '2017-03-01 17:00:00' }
        let(:promoted) { false }
        it 'does not include os tags' do
          [
            '#SFOS',
            '#SFopenstudios',
            '#missionopenstudios',
            '#springopenstudios',
          ].each do |tag|
            expect(presenter.hash_tags).not_to include tag
          end
        end
      end
    end
  end
end
