require 'spec_helper'

describe StudioImage do

  describe '#save' do
    let(:file) { Faker::Files.file }
    let(:upload) { double('UploadedFile', :original_filename => file) }
    before do
      Studio.any_instance.stub(:compute_geocode).and_return([33,-120])
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
end
