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
    let(:file) { Faker::Files.file }
    let(:upload) { {'datafile' => double('UploadedFile', :read => '', :original_filename => file, :close => '') } }
    let(:art_piece) { ArtPiece.first }
    let(:artist) { art_piece.artist }
    let(:image_info) { OpenStruct.new({:path => 'new_art_piece.jpg', :height => 1234, :width => 2233} ) }
    let(:mock_image_file) { double("MockImageFile", :save => image_info) }
    before do
      ArtPieceImage.new(art_piece, upload).save
    end

    it 'updates the filename' do
      art_piece.filename.should eql "new_art_piece.jpg"
    end
    it 'updates the image dimensions' do
      art_piece.image_height.should eql 1234
      art_piece.image_width.should eql 2233
    end
  end

end
