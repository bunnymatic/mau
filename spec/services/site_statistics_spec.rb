require 'rails_helper'

describe SiteStatistics do
  subject(:stats) { SiteStatistics.new }
  let!(:os) do
    [
      create(:open_studios_event, start_date: Time.zone.local(2021, 2, 2)),
      create(:open_studios_event, start_date: Time.zone.local(2020, 2, 2)),
    ]
  end
  let!(:models) do
    freeze_time do
      FactoryBot.create_list(:studio, 2)

      travel_to(16.hours.ago)
      FactoryBot.create(:artist, :active)

      travel_to(4.days.ago)
      FactoryBot.create_list(:artist, 2, :active, :with_art, :with_links)
      FactoryBot.create_list(:artist, 3)

      travel_to(10.days.ago)
      FactoryBot.create_list(:artist, 2, :active)
      FactoryBot.create_list(:artist, 3)
    end

    create_favorite(Artist.first, Artist.last)
    create_favorite(Artist.first, Artist.last(2).first)
    create_favorite(Artist.first, ArtPiece.first)
  end

  it 'assigns the correct social links' do
    expect(stats.social_links).to eql('website' => 5, 'facebook' => 2, 'twitter' => 2, 'instagram' => 2)
  end

  it 'assigns correct values for favorites' do
    expect(stats.totals[:favorites_users_using]).to eql 1
    expect(stats.totals[:favorited_art_pieces]).to eql 1
    expect(stats.totals[:favorited_artists]).to eql 2
  end

  it 'assigns correct values for artists counts at different time points' do
    expect(stats.yesterday[:artists_added]).to eql 1
    expect(stats.yesterday[:artists_activated]).to eql 1

    expect(stats.last_week[:artists_activated]).to eql 3
    expect(stats.last_week[:artists_added]).to eql 6

    expect(stats.last_30_days[:artists_activated]).to eql 5
    expect(stats.last_30_days[:artists_added]).to eql 11
  end
  it 'has totals' do
    expect(stats.totals).to be
    expect(stats.totals[:studios]).to eql 2
  end
  it 'has open studios info' do
    expect(stats.open_studios.length).to be >= 2
  end
end
