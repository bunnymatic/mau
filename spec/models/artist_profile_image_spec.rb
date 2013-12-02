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
    it "returns the right path where size is thumb" do
      (ArtistProfileImage.get_path(artist, :thumb)).should eql('/'+ [directory,artist.id,'profile','t_'+artist.profile_image].join('/'))
    end
    it "returns the right path where size is cropped_thumb" do
      (ArtistProfileImage.get_path(artist, :cropped_thumb)).should eql('/'+ [directory,artist.id,'profile','ct_'+artist.profile_image].join('/'))
    end
    it "returns the right path where size is small" do
      (ArtistProfileImage.get_path(artist, :small)).should eql('/'+ [directory,artist.id,'profile','s_'+artist.profile_image].join('/'))
    end
    it "returns the right path where size is medium" do
      (ArtistProfileImage.get_path(artist, :medium)).should eql('/'+  [directory,artist.id,'profile','m_'+artist.profile_image].join('/'))
      (ArtistProfileImage.get_path(artist)).should eql('/'+  [directory,artist.id,'profile','m_'+artist.profile_image].join('/'))
    end
    it "returns the right path where size is large" do
      (ArtistProfileImage.get_path(artist, :large)).should eql("/"+ [directory,artist.id,'profile','l_'+artist.profile_image].join('/'))
    end
    it "returns the right path where size is original" do
      (ArtistProfileImage.get_path(artist, :original)).should eql("/"+ [directory,artist.id,'profile',artist.profile_image].join('/'))
    end
  end

end
