require 'spec_helper'

describe ArtPiece do
  
  let(:valid_attrs) { FactoryGirl.attributes_for(:art_piece) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:art_piece) { artist.art_pieces.first }

  it_should_behave_like ImageDimensions

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
      Rails.cache.clear
      Rails.cache.should_receive(:delete).with("%s%s" % [Artist::CACHE_KEY, artist.id]).at_least(1).times
      Rails.cache.should_receive(:delete).with(ArtPiece::NEW_ART_CACHE_KEY)
      art_piece.title = Faker::Lorem.words(2).join(' ')
      art_piece.save
    end
  end

  describe '#dimensions' do
    let(:width) { nil }
    let(:height) { nil }
    let(:art_piece) { FactoryGirl.build(:art_piece, image_height: height, image_width: width) }

    context 'with no dimensions' do
      it 'computes proper dimension' do
        art_piece.compute_dimensions[:small].should == [0,0]
      end
    end

    context 'with negative dimensions' do
      let(:width) { -100 }
      it 'computes proper dimension' do
        art_piece.compute_dimensions[:small].should == [0,0]
      end
    end

    context 'with real dimensions' do
      let(:width) { 1000 }
      let(:height) { 1500 }
      it 'computes proper dimension' do
        art_piece.compute_dimensions[:small].should == [133,200]
      end
    end
  end

  describe "get_new_art" do
    before do
      Rails.cache.stub(:read => nil)
      Timecop.freeze

      (13 - ArtPiece.count).times do |n|
        Timecop.travel (n+1).days.ago
        FactoryGirl.create :artist, :with_art
      end
    end
    after do
      Timecop.return
    end
    it 'returns an array' do
      ArtPiece.get_new_art.should be_a_kind_of Array
    end
    it 'returns art pieces updated between today and 2 days ago' do
      aps = ArtPiece.get_new_art
      aps.length.should eq 12
      aps.map(&:created_at).should be_monotonically_decreasing
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
      art_piece.get_path.should match %r{/artistdata/#{artist.id}/imgs}
    end
  end

  describe 'destroy' do
    it 'tries to delete the files associated with this art piece' do
      File.stub('exist?' => true)
      File.should_receive(:delete).exactly(art_piece.get_paths.length).times
      art_piece.destroy
    end
  end

  describe 'to_json' do
    before do
      @ap = JSON.parse(art_piece.to_json)['art_piece']
    end
    it 'includes the filename' do
      @ap.keys.should include 'filename'
    end
    it 'includes paths to all art pieces' do
      @ap.keys.should include 'image_urls'
      ['small','medium','large'].each do |sz|
        @ap['image_urls'].keys.should include sz
        @ap['image_urls'][sz].should include Conf.site_url
      end
      @ap['image_urls']['small'].should == "http://#{Conf.site_url}/artistdata/#{artist.id}/imgs/s_#{art_piece.filename}"
    end
  end
end
