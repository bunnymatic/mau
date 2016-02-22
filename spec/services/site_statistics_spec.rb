require 'rails_helper'

describe SiteStatistics do

  subject(:stats) { SiteStatistics.new }

  before do
    fix_leaky_fixtures

    Timecop.freeze

    FactoryGirl.create_list(:studio, 2)

    Timecop.travel(16.hours.ago)
    FactoryGirl.create(:artist, :active)

    Timecop.travel(4.days.ago)
    FactoryGirl.create_list(:artist, 2, :active, :with_art)
    FactoryGirl.create_list(:artist, 3)

    Timecop.travel(10.days.ago)
    FactoryGirl.create_list(:artist, 2, :active)
    FactoryGirl.create_list(:artist, 3)

    Timecop.return

    Artist.first.add_favorite(Artist.last)
    Artist.first.add_favorite(Artist.last(2).first)
    Artist.first.add_favorite(ArtPiece.first)
  end

  it 'assigns correct values for favorites' do
    expect(stats.totals[:favorites_users_using]).to eql 1
    expect(stats.totals[:favorited_art_pieces]).to eql 1
    expect(stats.totals[:favorited_artists]).to eql 2
  end

  it 'assigns correct values for artists yesterday' do
    expect(stats.yesterday[:artists_added]).to eql 1
    expect(stats.yesterday[:artists_activated]).to eql 1
  end
  it 'assigns correct values for artists last week' do
    expect(stats.last_week[:artists_activated]).to eql 3
    expect(stats.last_week[:artists_added]).to eql 6
  end
  it 'assigns correct values for artists last month' do
    expect(stats.last_30_days[:artists_activated]).to eql 5
    expect(stats.last_30_days[:artists_added]).to eql 11
  end
  it 'has totals' do
    expect(stats.totals).to be
  end
  it 'has studio count' do
    expect(stats.totals[:studios]).to eql 2
  end
  it 'has open studios info' do
    expect(stats.open_studios.length).to be >= 5
  end
end
