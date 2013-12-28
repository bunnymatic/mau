require 'spec_helper'

describe ArtistProfileImage do

  fixtures :users, :artist_infos, :studios

  describe '#save' do
    let(:file) { Faker::Files.file }
    let(:upload) { double('UploadedFile', :original_filename => file) }
    let(:image_info) { OpenStruct.new({:path => 'artist_image.jpg', :height => 1234, :width => 2233} ) }

    before do
      @artist = users(:artist1)
      ImageFile.should_receive(:save).with(upload,
                                           "public/artistdata/#{@artist.id}/profile",
                                           "profile#{File.extname(file)}" ).and_return(image_info)
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

  describe '#get_path' do
    let(:artist) { users(:artist1) }
    let(:directory) { 'artistdata' }
    let(:size) { :thumb }
    let(:prefix) { 't_' }
    let(:expected_path) {
      ('/'+ [directory,artist.id,'profile', prefix+artist.profile_image].join('/'))
    }
    context 'thumb' do
      it 'returns the right path' do
        (ArtistProfileImage.get_path(artist, size)).should eql expected_path
      end
    end
    context 'cropped_thumb' do
      let(:size) { :cropped_thumb }
      let(:prefix) { 'ct_' }
      it 'returns the right path' do
        (ArtistProfileImage.get_path(artist, size)).should eql expected_path
      end
    end

    context 'small' do
      let(:size) { :small }
      let(:prefix) { 's_' }
      it 'returns the right path' do
        (ArtistProfileImage.get_path(artist, size)).should eql expected_path
      end
    end
    context 'medium' do
      let(:size) { :medium }
      let(:prefix) { 'm_' }
      it 'returns the right path' do
        (ArtistProfileImage.get_path(artist, size)).should eql expected_path
      end
    end
    context 'large' do
      let(:size) { :large }
      let(:prefix) { 'l_' }
      it 'returns the right path' do
        (ArtistProfileImage.get_path(artist, size)).should eql expected_path
      end
    end
    context 'original' do
      let(:size) { :original }
      let(:prefix) { '' }
      it 'returns the right path' do
        (ArtistProfileImage.get_path(artist, size)).should eql expected_path
      end
    end
  end
end
