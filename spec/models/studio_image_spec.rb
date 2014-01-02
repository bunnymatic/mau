require 'spec_helper'

describe StudioImage do

  let (:studio) { FactoryGirl.create(:studio) }

  describe '#save' do
    let(:file) { Faker::Files.file }
    let(:upload) { {'datafile' => double('UploadedFile', :original_filename => file) } }
    let(:image_info) { OpenStruct.new({:path => 'studio_image.jpg', :height => 1234, :width => 2233} ) }
    let(:mock_image_file) { double("MockImageFile", :save => image_info) }

    let (:writable) { double('Writable',:write => nil) }

    subject(:studio_image) { StudioImage.new(upload, studio) }

    before do
      ImageFile.should_receive(:new).with(upload,
                                          "public/studiodata/#{studio.id}/profile",
                                          "profile#{File.extname(file)}" ).and_return(mock_image_file)
      studio_image.save
      studio.reload
    end

    it 'updates the filename' do
      studio.profile_image.should eql "studio_image.jpg"
    end
    it 'updates the image dimensions' do
      studio.image_height.should eql 1234
      studio.image_width.should eql 2233
    end
  end

  describe '#get_path' do
    let(:directory) { 'studiodata' }
    let(:size) { :thumb }
    let(:prefix) { 't_' }
    let(:expected_path) {
      ('/'+ [directory,studio.id,'profile', prefix+studio.profile_image].join('/'))
    }
    context 'thumb' do
      it 'returns the right path' do
        (StudioImage.get_path(studio, size)).should eql expected_path
      end
    end
    context 'cropped_thumb' do
      let(:size) { :cropped_thumb }
      let(:prefix) { 'ct_' }
      it 'returns the right path' do
        (StudioImage.get_path(studio, size)).should eql expected_path
      end
    end

    context 'small' do
      let(:size) { :small }
      let(:prefix) { 's_' }
      it 'returns the right path' do
        (StudioImage.get_path(studio, size)).should eql expected_path
      end
    end
    context 'medium' do
      let(:size) { :medium }
      let(:prefix) { 'm_' }
      it 'returns the right path' do
        (StudioImage.get_path(studio, size)).should eql expected_path
      end
    end
    context 'large' do
      let(:size) { :large }
      let(:prefix) { 'l_' }
      it 'returns the right path' do
        (StudioImage.get_path(studio, size)).should eql expected_path
      end
    end
    context 'original' do
      let(:size) { :original }
      let(:prefix) { '' }
      it 'returns the right path' do
        (StudioImage.get_path(studio, size)).should eql expected_path
      end
    end

  end

end
