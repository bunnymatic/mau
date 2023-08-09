require 'rails_helper'

describe ArtistsPresenter do
  include PresenterSpecHelpers

  let!(:artists) { FactoryBot.create_list :artist, 4, :with_art, :in_the_mission }

  describe '#artists' do
    context 'with no params' do
      subject(:presenter) { ArtistsPresenter.new }
      it 'shows all active artists sorted by name' do
        expect(subject.artists.map(&:artist)).to eql Artist.active.sort_by(&:sortable_name).to_a
      end
    end

    describe 'os_only flag' do
      let(:os_only) { false }
      subject(:presenter) { ArtistsPresenter.new(os_only:) }

      context 'os_only is false' do
        it 'shows active artists sorted by name' do
          expect(subject.artists).to have(4).artists
          expect(subject.artists.map(&:artist)).to eql Artist.active.sort_by(&:sortable_name).to_a
        end
      end

      context 'os_only is true' do
        let(:os_only) { true }
        context 'when there is an open studios event' do
          let(:os_participants) { OpenStudiosParticipant.all.map(&:user) }
          before do
            artists.first.open_studios_events << create(:open_studios_event)
          end
          it 'shows only os artists' do
            expected = os_participants.select(&:in_the_mission?).sort_by(&:sortable_name).to_a
            expect(subject.artists.map(&:artist).to_a).to eql(expected)
          end
        end
        context 'when there is no current open studios event' do
          it 'shows returns none' do
            expect(subject.artists.to_a).to eql([])
          end
        end
      end
    end

    describe 'sort_by_name flag' do
      let(:sort_by_name) { false }
      let!(:artists) do
        [
          FactoryBot.create(:artist, :with_art, :in_the_mission, firstname: 'Bb', lastname: 'bb', nomdeplume: nil),
          FactoryBot.create(:artist, :with_art, :in_the_mission, firstname: 'AA', lastname: 'AA', nomdeplume: nil),
          FactoryBot.create(:artist, :with_art, :in_the_mission, firstname: 'ZZ', lastname: 'zz', nomdeplume: nil),
        ]
      end
      subject(:presenter) { ArtistsPresenter.new(sort_by_name:) }
      context 'sort_by_name is false' do
        it 'is returned unsorted' do
          artists_names = subject.artists.map(&:sortable_name)
          expect(artists_names).not_to be_monotonically_increasing
          expect(artists_names).not_to be_monotonically_decreasing
        end
      end
    end
  end
end
