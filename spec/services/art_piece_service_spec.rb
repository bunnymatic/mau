require 'spec_helper'
describe ArtPieceService do
  let(:service) { ArtPieceService }
  before do
    Rails.cache.clear
  end
  describe "get_new_art" do
    let(:older) {
      olders = 3.times.map{ |idx|
        FactoryGirl.create :artist, :with_art
      }
      olders.last
    }
    let(:newer) {
      Timecop.travel 1.day.ago
      FactoryGirl.create :artist, :with_art
    }
    before do
      Rails.cache.stub(:read => nil)
      newer
      older
      Timecop.freeze
    end
    after do
      Timecop.return
    end
    it 'returns art pieces updated between today and 2 days ago' do
      aps = service.get_new_art(3)
      expect( aps ).to include newer.art_pieces.first
      expect( aps ).to_not include older.art_pieces.first
      expect( aps.map(&:created_at) ).to be_monotonically_decreasing
    end
    context 'from cache' do
      before do
        Rails.cache.stub(:read => [ArtPiece.last])
      end
      it 'returns pulls from the cache if available' do
        service.get_new_art.should == [ArtPiece.last]
      end
    end
  end
end
