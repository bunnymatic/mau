require 'spec_helper'

describe ArtistProfileImage do

  fixtures :users, :artist_infos, :studios, :roles

  describe '#save' do
    let(:file) { Faker::Files.file }
    let(:upload) { double('UploadedFile', :original_filename => file) }
    before do
      Artist.any_instance.stub(:compute_geocode).and_return([33,-120])
      @artist = users(:artist1)
      ImageFile.should_receive(:save).with(upload,
                                           "public/artistdata/#{@artist.id}/profile",
                                           "profile#{File.extname(file)}" ).and_return(['artist_image.jpg',1234,2233])
      ArtistProfileImage.save({'datafile' => upload}, @artist)
      @artist.reload
    end

    it 'updates the filename' do
      @artist.profile_image.should eql "artist_image.jpg"
    end
    it 'updates the image dimensions' do
      @artist.image_height.should eql 1234
      @artist.image_width.should eql 2233
    end
  end
end
