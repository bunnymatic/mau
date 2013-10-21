require 'spec_helper'

def valid_attrs()
  { :title => 'art piece',
  }
end

describe ArtPiece do
  fixtures :art_pieces, :users, :artist_infos

  it_should_behave_like ImageDimensions

  describe 'create'  do
    it 'should not allow short title' do
      ap = ArtPiece.new(:title => 't')
      ap.should_not be_valid
      ap.should have(1).errors_on(:title)
    end

    it 'should not allow empty title' do
      ap = ArtPiece.new
      ap.should_not be_valid
      ap.should have(2).errors
    end

    it 'allows quotes' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      ap.should be_valid
    end

    it 'encodes quotes to html numerically' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      ap.safe_title.should == 'what&#x22;ever'
    end
  end
  describe 'after save' do
    it 'clears representative image cache and new art cache on save' do
      ap = ArtPiece.first
      Rails.cache.should_receive(:delete).with("%s%s" % [Artist::CACHE_KEY, ap.artist.id])
      Rails.cache.should_receive(:delete).with(ArtPiece::NEW_ART_CACHE_KEY)
      ap.title = Faker::Lorem.words(2).join(' ')
      ap.save
    end
  end

  describe '#dimensions' do
    it 'computes proper dimension' do
      a = art_pieces(:hot)
      a.compute_dimensions[:small].should == [0,0]

      a = art_pieces(:negative_size)
      a.compute_dimensions[:medium].should == [0,0]
      a.compute_dimensions[:large].should == [0,0]

      a = art_pieces(:h1024w2048)
      a.compute_dimensions[:medium].should == [400,200]
      a.compute_dimensions[:large].should == [800,400]
    end
  end

  describe "get_new_art" do
    before do
      Rails.cache.stub(:read => nil)
      t = Time.zone.now
      Time.stub(:now => t)
      Time.zone.stub(:now => t)
    end
    it 'returns an array' do
      ArtPiece.get_new_art.should be_a_kind_of Array
    end
    it 'returns art pieces updated between today and 2 days ago' do
      all = ArtPiece.find_by_sql("select * from art_pieces").select{|a| a.artist_id}
      all.length.should >= 1
      aps = ArtPiece.get_new_art
      aps.length.should >=1
      aps.length.should <=12
      aps.sort_by(&:created_at).should == all[0..12].sort_by(&:created_at)
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

  describe '#add_tag' do
    it 'adds a tag to the art piece' do
      new_tag = Faker::Lorem.words(2).join(' ')
      ap = ArtPiece.first
      ap.add_tag(new_tag)
      ap.reload
      ap.art_piece_tags.map(&:name).should include new_tag
    end
  end


  describe 'get_path' do
    it 'returns a path to the art piece' do
      ap = ArtPiece.first
      artist = ap.artist
      ArtPiece.first.get_path.should match %r{/artistdata/#{artist.id}/imgs}
    end
  end

  describe 'destroy' do
    it 'tries to delete the files associated with this art piece' do
      File.stub('exist?' => true)
      ap = ArtPiece.first
      File.should_receive(:delete).exactly(ap.get_paths.length).times
      ap.destroy
    end
  end

  describe 'to_json' do
    before do
      @piece = ArtPiece.first
      @artist = @piece.artist
      @ap = JSON.parse(@piece.to_json)['art_piece']
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
      @ap['image_urls']['small'].should == "http://#{Conf.site_url}/artistdata/#{@artist.id}/imgs/s_#{@piece.filename}"
    end
  end
end
