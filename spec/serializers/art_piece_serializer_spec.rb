require 'spec_helper'

describe ArtPieceSerializer do
  let(:art_piece) { create(:art_piece, :with_tags) }
  let(:artist) { art_piece.artist }
  let(:serializer) { ArtPieceSerializer.new(art_piece) }
  describe 'to_json' do
    before do
      @ap = JSON.parse(serializer.to_json)['art_piece']
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
      expect(@ap['image_urls']['small']).to include "/system/art_pieces/photos"
    end

    it 'includes the fields we care about' do
      %w( id filename title artist_id
          year tags medium
          image_files artist_name ).each do |expected|
        expect(@ap).to have_key expected
      end
    end

    it 'includes paths to the images' do
      sizes = ['cropped_thumb','large','medium','original', 'small','thumb']
      files = @ap['image_files']
      expect(files.keys.sort).to eql sizes
      sizes.each do |sz|
        expect(files[sz]).to eql art_piece.get_path(sz)
      end
    end

    it 'includes the tags' do
      @ap['tags'].should be_a_kind_of Array
      @ap['tags'].first['name'].should eql art_piece.tags.first.name
    end
    it 'includes the artists name' do
      @ap['artist_name'].should eql html_encode(art_piece.artist.full_name)
    end
    it 'includes the art piece title' do
      @ap['title'].should eql art_piece.title
    end
    it 'includes the medium' do
      @ap['medium']['name'].should eql art_piece.medium.name
    end

  end
end
