require 'spec_helper'


describe ImageFile do

  it 'sizes respond to height and width and prefix for all sizes' do
    ImageFile.sizes.keys.each do |sz_key|
      [:height, :width, :prefix].each do |key|
        (ImageFile.sizes[sz_key].respond_to? key).should be
      end
    end
  end
  ['original', 'orig' ].each do |size|
    it "get_path for #{size} returns a file name with no prefix" do
      fname = ImageFile.get_path('dir',size,'myfile.jpg')
      fname.should match /dir\/myfile\.jpg$/
    end
  end
  ['large'].each do |size|
    it "get_path for #{size} returns a file name with l_ as a prefix" do
      fname = ImageFile.get_path('dir',size,'myfile.jpg')
      fname.should match /dir\/l_myfile\.jpg$/
    end
  end
  ['medium', 'standard'].each do |size|
    it "get_path for #{size} returns a file name with m_ as a prefix" do
      fname = ImageFile.get_path('dir',size,'myfile.jpg')
      fname.should match /dir\/m_myfile\.jpg$/
    end
  end
  ['thumb','thumbnail'].each do |size|
    it "get_path for #{size} returns a file name with m_ as a prefix" do
      fname = ImageFile.get_path('dir',size,'myfile.jpg')
      fname.should match /dir\/t_myfile\.jpg$/
    end
  end
  ['cropped_thumb'].each do |size|
    it "get_path for #{size} returns a file name with m_ as a prefix" do
      fname = ImageFile.get_path('/dir/',size,'myfile.jpg')
      fname.should match /dir\/ct_myfile\.jpg$/
    end
  end

  describe 'clean_filename' do
    [['fname.jpg', 'fname.jpg'],
     ['f & name.jpg', 'fname.jpg'],
     ['f & *#q45sd  name.jpg', 'fq45sdname.jpg'],
     ['fname .jpg', 'fname.jpg']].each do |f|
      it "cleans #{f[0]} to #{f[1]}" do
        (ImageFile.clean_filename f[0]).should eql f[1]
      end
    end
  end

  describe '#get_path' do
    let(:directory) { Faker::Files.dir }
    let(:file) { Faker::Files.file }
    it "returns the right path where size is thumb" do
      (ImageFile.get_path(directory,:thumb,file)).should eql([directory,'t_' +file].join '/')
    end
    it "returns the right path where size is cropped_thumb" do
      (ImageFile.get_path(directory,:cropped_thumb,file)).should eql([directory,'ct_' +file].join '/')
    end
    it "returns the right path where size is small" do
      (ImageFile.get_path(directory,:small,file)).should eql([directory,'s_' +file].join '/')
    end
    it "returns the right path where size is medium" do
      (ImageFile.get_path(directory,:medium,file)).should eql([directory,'m_' +file].join '/')
    end
    it "returns the right path where size is large" do
      (ImageFile.get_path(directory,:large,file)).should eql([directory,'l_' +file].join '/')
    end
    it "returns the right path where size is original" do
      (ImageFile.get_path(directory,:original,file)).should eql([directory,file].join '/')
    end
  end


  it_should_behave_like ImageFileHelpers
end
