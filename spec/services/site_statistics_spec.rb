require 'spec_helper'

describe SiteStatistics do

  subject(:stats) { SiteStatistics.new }

  before do
    fix_leaky_fixtures

    Timecop.freeze

    FactoryGirl.create_list(:studio, 2)

    Timecop.travel(16.hours.ago)
    FactoryGirl.create(:artist, :active)

    Timecop.travel(4.days.ago)
    FactoryGirl.create_list(:artist, 2, :active)
    FactoryGirl.create_list(:artist, 3)

    Timecop.travel(10.days.ago)
    FactoryGirl.create_list(:artist, 2, :active)
    FactoryGirl.create_list(:artist, 3)

    Timecop.return
  end

  it 'assigns correct values for artists yesterday' do
    stats.yesterday[:artists_added].should eql 1
    stats.yesterday[:artists_activated].should eql 1
  end
  it 'assigns correct values for artists last week' do
    stats.last_week[:artists_activated].should eql 3
    stats.last_week[:artists_added].should eql 6
  end
  it 'assigns correct values for artists last month' do
    stats.last_30_days[:artists_activated].should eql 5
    stats.last_30_days[:artists_added].should eql 11
  end
  it 'has totals' do
    stats.totals.should be
  end
  it 'has studio count' do
    stats.totals[:studios].should eql 2
  end
  it 'has open studios info' do
    stats.open_studios.length.should >= 5
  end
end
