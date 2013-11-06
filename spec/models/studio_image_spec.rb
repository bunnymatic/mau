require 'spec_helper'

describe StudioImage do

  describe '#save' do
    let(:file) { Faker::Files.file }
    let(:upload) { double('UploadedFile', :original_filename => file) }
    before do
      @studio = FactoryGirl.create(:studio)
      ImageFile.should_receive(:save).with(upload,
                                           "public/studiodata/#{@studio.id}/profile",
                                           "profile#{File.extname(file)}" ).and_return(['studio_image.jpg',1234,2233])
      StudioImage.save({'datafile' => upload}, @studio)
      @studio.reload
    end

    it 'updates the filename' do
      @studio.profile_image.should eql "studio_image.jpg"
    end
    it 'updates the image dimensions' do
      @studio.image_height.should eql 1234
      @studio.image_width.should eql 2233
    end
  end

  describe '#get_path' do
    let(:studio) { FactoryGirl.create(:studio) }
    let(:directory) { 'studiodata' }
    it "returns the right path where size is thumb" do
      (StudioImage.get_path(studio, :thumb)).should eql('/'+ [directory,studio.id,'profile','t_'+studio.profile_image].join('/'))
    end
    it "returns the right path where size is cropped_thumb" do
      (StudioImage.get_path(studio, :cropped_thumb)).should eql('/'+ [directory,studio.id,'profile','ct_'+studio.profile_image].join('/'))
    end
    it "returns the right path where size is small" do
      (StudioImage.get_path(studio, :small)).should eql('/'+ [directory,studio.id,'profile','s_'+studio.profile_image].join('/'))
    end
    it "returns the right path where size is medium" do
      (StudioImage.get_path(studio, :medium)).should eql('/'+  [directory,studio.id,'profile','m_'+studio.profile_image].join('/'))
      (StudioImage.get_path(studio)).should eql('/'+  [directory,studio.id,'profile','m_'+studio.profile_image].join('/'))
    end
    it "returns the right path where size is large" do
      (StudioImage.get_path(studio, :large)).should eql("/"+ [directory,studio.id,'profile','l_'+studio.profile_image].join('/'))
    end
    it "returns the right path where size is original" do
      (StudioImage.get_path(studio, :original)).should eql("/"+ [directory,studio.id,'profile',studio.profile_image].join('/'))
    end
  end

end
