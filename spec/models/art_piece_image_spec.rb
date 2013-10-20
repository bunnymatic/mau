require 'spec_helper'

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
    let(:upload) { double('UploadedFile', :original_filename => file) }
    let(:art_piece) { ArtPiece.first }
    let(:artist) { art_piece.artist }
    before do
      ImageFile.should_receive(:save).with(upload,
                                           "public/artistdata/#{artist.id}/imgs/").and_return(['new_art_piece.jpg',1234,2233])
      ArtPieceImage.save({'datafile' => upload}, art_piece)
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
