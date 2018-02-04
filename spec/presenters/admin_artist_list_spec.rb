# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

describe AdminArtistList, elasticsearch: :stub do
  include PresenterSpecHelpers

  let!(:artists) do
    FactoryBot.create(:artist, :active)
    FactoryBot.create(:artist, :with_studio)
    FactoryBot.create(:artist, :with_art)
    FactoryBot.create(:artist, :pending)
    FactoryBot.create(:artist, :deleted)
    FactoryBot.create(:artist, :suspended)
  end

  let(:parsed) { CSV.parse(list.csv, headers: true) }

  subject(:list) { AdminArtistList.new }

  its(:csv_filename) { is_expected.to eql 'mau_artists.csv' }

  it 'has correct data in the csv' do
    expect(parsed.first['Full Name']).to eql list.artists.first.full_name
  end
end
