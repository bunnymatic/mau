# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

describe AdminArtistList, elasticsearch: :stub do
  include PresenterSpecHelpers

  let!(:artists) do
    FactoryBot.create(:artist, :active, updated_at: 1.months.ago)
    FactoryBot.create(:artist, :with_studio, updated_at: 2.months.ago)
    FactoryBot.create(:artist, :with_art, updated_at: 3.months.ago)
    FactoryBot.create(:artist, :pending, updated_at: 4.months.ago)
    FactoryBot.create(:artist, :deleted, updated_at: 5.months.ago)
    FactoryBot.create(:artist, :suspended, updated_at: 6.weeks.ago)
    FactoryBot.create(:artist, :pending, updated_at: 7.months.ago)
    FactoryBot.create(:artist, :deleted, updated_at: 8.months.ago)
    FactoryBot.create(:artist, :suspended, updated_at: 9.months.ago)
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
