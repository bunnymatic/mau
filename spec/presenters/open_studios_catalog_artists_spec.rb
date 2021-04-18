require 'rails_helper'

describe OpenStudiosCatalogArtists do
  let(:presenter) { described_class.new }
  let(:os) { create(:open_studios_event, :with_current_special_event) }
  let!(:artists) do
    list = [
      FactoryBot.create(:artist, :active, :with_art),
      FactoryBot.create(:artist, :active, :with_art, lastname: 'AA'),
      FactoryBot.create(:artist, :active, :with_art, lastname: 'TT'),
      FactoryBot.create(:artist, :active, :with_art, lastname: 'GG'),
      FactoryBot.create(:artist, :active),
    ]
    list.last(4).each { |a| a.open_studios_events << os }
    list
  end

  it 'returns artists sorted by name' do
    expect(presenter.artists.map(&:lastname)).to eq %w[AA GG TT]
  end

  it 'returns only os artists with art' do
    expect(presenter.artists).to have(3).artists
  end

  describe 'when artists are broadcasting' do
    before do
      artists[2..3].each do |artist|
        info = artist.current_open_studios_participant
        info.video_conference_url = 'http://something.com'
        info.video_conference_schedule = os.special_event_time_slots.index_with { |_ts| true }
        info.save!
      end
    end
    it 'they are sorted preferentially by broadcasting, then by name' do
      expect(presenter.artists.map(&:lastname)).to eq %w[GG TT AA]
    end
  end
end
