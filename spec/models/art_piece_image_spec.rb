require 'spec_helper'
require 'ostruct'

describe ArtPieceImage do
  fixtures :users, :art_pieces, :artist_infos
  describe '#get_path' do
    it 'returns the missing image path given nothing' do
      ArtPieceImage.get_path('bogus').should match /missing_artpiece/
    end
    it 'returns nil if the artpiece has no artist' do
      ArtPieceImage.get_path(ArtPiece.new).should match /missing_artpiece/
    end
    it 'returns nil if the artpiece has no artist' do
      ArtPiece.any_instance.stub(:filename).and_return nil
      ArtPieceImage.get_path(ArtPiece.last).should match /missing_artpiece/
    end
  end

  describe '#save' do

    let(:file) { 'filename.jpg' }
    let(:path) { 'whatever/' + file }
    let(:upload) { {'datafile' => double('UploadedFile', :read => '', :original_filename => path, :close => '') } }
    let(:art_piece) { ArtPiece.first }
    let(:artist) { art_piece.artist }

    before do
      now = Time.zone.now
      Time.zone.stub(:now => now)
      MojoMagick.stub(:resize => nil, :raw_command => 'JPG 100 200 RGB')

      ArtPieceImage.new(art_piece, upload).save
    end

    it 'updates the filename' do
      art_piece.filename.should match %r{public/artistdata/#{artist.id}/imgs/#{Time.zone.now.to_i}#{file}$}
    end

    it 'updates the image dimensions' do
      art_piece.image_height.should eql 100
      art_piece.image_width.should eql 200
    end
  end

end
