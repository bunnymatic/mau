require 'spec_helper'

describe ArtPiece do

  let(:valid_attrs) { FactoryGirl.attributes_for(:art_piece) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:art_piece) { artist.art_pieces.first }

  it{ should validate_presence_of(:title) }
  it{ should ensure_length_of(:title).is_at_least(2).is_at_most(80) }

  describe 'create'  do
    it 'allows quotes' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      ap.should be_valid
    end

    it 'encodes quotes to html numerically' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      ap.safe_title.should == 'what&quot;ever'
    end
  end
  describe 'after save' do
    it 'clears representative image cache and new art cache on save' do
      Rails.cache.should_receive(:delete).with("%s%s" % [Artist::CACHE_KEY, artist.id]).at_least(1).times
      Rails.cache.should_receive(:delete).with(ArtPiece::NEW_ART_CACHE_KEY)
      art_piece.title = Faker::Lorem.words(2).join(' ')
      art_piece.save
    end
  end

  describe "get_new_art" do
    let(:older) {
      olders = 3.times.map{ |idx|
        Timecop.travel idx.days.ago
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
      aps = ArtPiece.get_new_art(2)

      expect( aps ).to include newer.art_pieces.first
      expect( aps ).to_not include older.art_pieces.first
      expect( aps.map(&:created_at) ).to be_monotonically_decreasing
    end
    context 'from cache' do
      before do
        Rails.cache.stub(:read => [ArtPiece.last])
      end
      it 'returns pulls from the cache if available' do
        ArtPiece.get_new_art.should == [ArtPiece.last]
      end
    end
  end

  describe 'get_path' do
    it 'returns a path to the art piece' do
      art_piece.get_path.should match %r{/system/art_pieces/.*/new-studio.jpg}
    end
  end

  describe 'destroy' do
    it 'tries to delete the files associated with this art piece' do
      File.stub('exist?' => true)
      File.should_receive(:delete).exactly(art_piece.get_paths.length).times
      art_piece.destroy
    end
  end

end
