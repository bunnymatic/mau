require 'spec_helper'

describe SiteStatistics do
  fixtures :art_pieces
  fixtures :artist_infos
  fixtures :studios
  fixtures :media
  fixtures :users, :roles_users, :roles, :events

  subject(:stats) { SiteStatistics.new }

  it 'the fixtures are in order' do
    expect(Event.count).to be > 1
  end

  it 'assigns correct values for artists yesterday' do
    stats.yesterday[:artists_activated].should eql 1
    stats.yesterday[:artists_added].should eql 1
  end
  it 'assigns correct values for artists last weeek' do
    stats.last_week[:artists_activated].should eql 4
    stats.last_week[:artists_added].should eql 7
  end
  it 'assigns correct values for artists last month' do
    stats.last_30_days[:artists_activated].should eql 6
    stats.last_30_days[:artists_added].should eql 12
  end
  it 'has totals' do
    stats.totals.should be
  end
  it 'has studio count' do
    stats.totals[:studios].should eql 4
  end
  it 'has event info' do
    stats.totals[:events_past].should eql Event.past.count
    stats.totals[:events_future].should eql Event.future.count
  end
  it 'has open studios info' do
    stats.open_studios.length.should >= 5
  end
end
