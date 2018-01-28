# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

describe AdminArtistList do
  include PresenterSpecHelpers

  let!(:artists) do
    FactoryBot.create(:artist, :active)
    FactoryBot.create(:artist, :with_studio)
    FactoryBot.create(:artist, :with_art)
    FactoryBot.create(:artist, :pending)
  end

  let(:parsed) { CSV.parse(list.csv, headers: true) }

  subject(:list) { AdminArtistList.new }

  describe '#csv_filename' do
    its(:csv_filename) { is_expected.to eql 'mau_artists.csv' }
  end

  describe '#csv_headers' do
    its(:csv_headers) { is_expected.to eql parsed.headers }
  end
  it 'has correct data in the csv' do
    expect(parsed.first['Full Name']).to eql list.artists.first.full_name
  end
end
