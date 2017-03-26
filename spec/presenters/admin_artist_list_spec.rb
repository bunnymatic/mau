# frozen_string_literal: true
require 'rails_helper'
require 'capybara/rspec'

describe AdminArtistList do
  include PresenterSpecHelpers

  let!(:artists) do
    FactoryGirl.create(:artist, :active)
    FactoryGirl.create(:artist, :with_studio)
    FactoryGirl.create(:artist, :with_art)
    FactoryGirl.create(:artist, :pending)
  end

  let(:parsed) { CSV.parse(list.csv, headers: true) }

  subject(:list) { AdminArtistList.new }

  describe '#csv_filename' do
    its(:csv_filename) { should eql 'mau_artists.csv' }
  end

  describe '#csv_headers' do
    its(:csv_headers) { should eql parsed.headers }
  end
  it 'has correct data in the csv' do
    expect(parsed.first['Full Name']).to eql list.artists.first.full_name
  end
end
