require 'rails_helper'
require 'capybara/rspec'

describe AdminArtistList, elasticsearch: false do
  include PresenterSpecHelpers

  let(:active_artists) do
    double('Artist::ActiveRecord_Relation',
           order: [
             FactoryBot.build_stubbed(:artist, :active, updated_at: 1.month.ago),
           ])
  end

  let(:pending_artists) do
    double('Artist::ActiveRecord_Relation',
           order: [
             FactoryBot.build_stubbed(:artist, :pending, updated_at: 4.months.ago),
             FactoryBot.build_stubbed(:artist, :pending, updated_at: 7.months.ago),
           ])
  end

  let(:bad_standing_artists) do
    double('Artist::ActiveRecord_Relation',
           order: [
             FactoryBot.build_stubbed(:artist, :suspended, updated_at: 6.weeks.ago),
             FactoryBot.build_stubbed(:artist, :deleted, updated_at: 5.months.ago),
             FactoryBot.build_stubbed(:artist, :deleted, updated_at: 8.months.ago),
             FactoryBot.build_stubbed(:artist, :suspended, updated_at: 9.months.ago),
           ])
  end

  let(:artists) do
    pending_artists.order + active_artists.order
  end

  before do
    freeze_time
    mock_artists_relation = double('Artist::ActiveRecord_Relation',
                                   all: artists,
                                   first: artists[0],
                                   bad_standing: bad_standing_artists,
                                   pending: pending_artists,
                                   active: active_artists)
    allow(Artist).to receive(:includes).and_return(mock_artists_relation)
  end

  subject(:list) { AdminArtistList.new }

  describe '.good_standing_artists' do
    let(:artist_list) { list.good_standing_artists }
    it 'includes artists who are not pending, suspended or deleted' do
      expect(artist_list.pluck(:state).uniq).to eq %w[active]
    end
    it 'returns artists ordered by updated at desc' do
      expect(artist_list.pluck(:updated_at)).to be_monotonically_decreasing
    end
  end

  describe '.pending' do
    let(:artist_list) { list.pending_artists }
    it 'includes artists who are pending' do
      expect(artist_list.pluck(:state).uniq).to eq %w[pending]
    end
    it 'returns artists ordered by updated at desc' do
      expect(artist_list.pluck(:updated_at)).to be_monotonically_decreasing
    end
  end

  describe '.bad_standing_artists' do
    let(:artist_list) { list.bad_standing_artists }
    it 'includes artists who are suspended or deleted' do
      expect(artist_list.pluck(:state).uniq).to match_array %w[suspended deleted]
    end
    it 'returns artists ordered by updated at desc' do
      expect(artist_list.pluck(:updated_at)).to be_monotonically_decreasing
    end
  end

  describe '.csv' do
    let(:parsed) { CSV.parse(list.csv, headers: true) }

    its(:csv_filename) { is_expected.to eql 'mau_artists.csv' }

    it 'has some data in the csv' do
      expect(parsed.first['Full Name']).to eql list.send(:artists).first.full_name
      expect(parsed.first.key?('Phone')).to be true
      expect(parsed.first.key?('Shop Url')).to be true
      expect(parsed.first.key?('No Current Open Studios')).to be true
    end

    describe 'when there is a current open studios with participants' do
      let(:os_event) { create(:open_studios_event, :with_special_event) }
      let(:artists) do
        Time.use_zone(Conf.event_time_zone) do
          os_event
          artist_list = create_list(:artist, 2, :active, :with_art, :with_phone, doing_open_studios: true, last_request_at: 2.days.ago)
          artist_list.sort_by!(&:lastname)
          artist_list[0].update!(phone: '2345678901')
          info = artist_list[0].current_open_studios_participant
          info.show_email = true
          info.show_phone_number = true
          info.youtube_url = 'https://www.youtube.com/watch?v=23ihawJKZcE'
          info.video_conference_url = 'http://video.example.com'
          info.shop_url = 'http://shop.example.com'
          info.save

          info = artist_list[1].current_open_studios_participant
          info.show_email = false
          info.shop_url = 'http://shop.example.com'
          info.video_conference_schedule = os_event.special_event_time_slots.each_slice(2).map(&:first).index_with { |_ts| true }
          info.save
          artist_list
        end
      end

      xit 'includes last seen and member since' do
        Time.use_zone(Conf.event_time_zone) do
          expected = {
            'Last Seen' => 2.days.ago.to_s(:admin),
            'Since' => Time.zone.now.strftime('%Y-%m-%d'),
            'Last Updated Profile' => Time.zone.now.to_s(:admin),
          }
          expect(parsed.first.to_h).to include(expected)
        end
      end

      it 'includes the phone number' do
        expected = {
          'Phone' => '2345678901',
        }
        expect(parsed.first.to_h).to include(expected)
      end

      it 'includes os participant info for the artists' do
        expected = {
          'Show Email' => 'true',
          'Video Conference Url' => 'http://video.example.com',
          "Participating in Open Studios #{os_event.for_display}" => 'true',
        }
        expect(parsed.first.to_h).to include(expected)
      end

      it 'includes os participant schedule columns' do
        # Because of the data setup, freeze_time was hard to get setup here.
        # instead, this test is hard to read but it grabs the schedule
        # and builds header names and makes sure they got set properly
        scheduled_slots = artists[1].current_open_studios_participant.video_conference_schedule.map { |(slot, scheduled)| slot if scheduled }

        Time.use_zone(Conf.event_time_zone) do
          # scheduled slots should be set true in the Csv
          schedule = scheduled_slots.map do |slot|
            OpenStudiosParticipant.parse_time_slot(slot).first
          end
          formatted = schedule.map { |start_time| start_time.to_s(:admin_with_zone) }
          expect(formatted).to have(4).timeslots
          formatted.each do |slot|
            expect(parsed[1].to_h[slot]).to eq 'true'
          end
        end
      end
    end
  end
end
