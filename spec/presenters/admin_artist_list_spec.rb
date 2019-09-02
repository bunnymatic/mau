# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

describe AdminArtistList, elasticsearch: false do
  include PresenterSpecHelpers

  let(:active_artists) do
    double('Artist::ActiveRecord_Relation', order: [
             FactoryBot.build_stubbed(:artist, :active, updated_at: 1.month.ago),
           ])
  end

  let(:pending_artists) do
    double('Artist::ActiveRecord_Relation', order: [
             FactoryBot.build_stubbed(:artist, :pending, updated_at: 4.months.ago),
             FactoryBot.build_stubbed(:artist, :pending, updated_at: 7.months.ago),
           ])
  end

  let(:bad_standing_artists) do
    double('Artist::ActiveRecord_Relation', order: [
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
    mock_artists_relation = double('Artist::ActiveRecord_Relation',
                                   all: artists,
                                   first: artists[0],
                                   bad_standing: bad_standing_artists,
                                   pending: pending_artists,
                                   active: active_artists)
    allow(Artist).to receive(:includes).and_return(mock_artists_relation)
  end

  let(:parsed) { CSV.parse(list.csv, headers: true) }

  subject(:list) { AdminArtistList.new }

  its(:csv_filename) { is_expected.to eql 'mau_artists.csv' }

  it 'has correct data in the csv' do
    expect(parsed.first['Full Name']).to eql list.send(:artists).first.full_name
  end

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
end
