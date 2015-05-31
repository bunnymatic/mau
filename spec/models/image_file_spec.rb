require 'spec_helper'


describe ImageFile do

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

  describe "#save" do
    let (:writable) { double('Writable',:write => nil) }
    let (:upload) { {'datafile' => double('Uploadable', :read => '', :original_filename => 'uploaded_file.jpg') } }
    let (:destdir) { 'destination/directory'}
    let (:destfile) { 'destfile.file' }
    let (:full_destpath) { File.join(destdir, destfile) }
    subject(:image_file) { ImageFile.new }

    before do
      Pathname.stub(:new => double("Path", :realpath => 'blah_de_blah'))
    end

    context 'with bad file extension' do
      let (:upload) { {'datafile' => double('Uploadable', :read => '', :original_filename => 'uploaded_file.csv') } }
      it 'does not allow upload' do
        expect {
          image_file.save upload, destdir, destfile
        }.to raise_error MauImage::ImageError
      end
    end

    context 'with no file extension' do
      let (:upload) { {'datafile' => double('Uploadable', :read => '', :original_filename => 'uploaded_file') } }
      it 'does not allow upload' do
        expect {
          image_file.save upload, destdir, destfile
        }.to raise_error MauImage::ImageError
      end
    end

    context 'with CMYK format image' do
      it 'disallows CMYK format' do
        MojoMagick.should_receive(:execute).
          with('identify', '-format "%m %h %w %r" ' + 'blah_de_blah').and_return(double('MojoMagick::CommandStatus', return_value:"JPG 12 14 CMYK"))
        File.should_receive(:open).with(full_destpath, 'wb').and_yield(writable)
        expect {
          image_file.save upload, destdir, destfile
        }.to raise_error MauImage::ImageError
      end
    end

    it 'sets up the right path name and calls resize for all the desired sizes' do
      MojoMagick.stub(:raw_command)
        MojoMagick.should_receive(:execute).
          with('identify', '-format "%m %h %w %r" ' + 'blah_de_blah').and_return(double('MojoMagick::CommandStatus', return_value:"JPG 12 14 RGB"))
      MojoMagick.should_receive(:resize).exactly(4).times
      File.should_receive(:open).with(full_destpath, 'wb').and_yield(writable)
      image_file.save upload, destdir, destfile
    end

    it 'sizes respond to height and width and prefix for all sizes' do
      image_file.sizes.keys.each do |sz_key|
        [:height, :width, :prefix].each do |key|
          image_file.sizes[sz_key].should respond_to key
        end
      end
    end

    it 'raises an error if MojoMagick::resize failse' do
      MojoMagick.should_receive(:execute).
        with('identify', '-format "%m %h %w %r" ' + 'blah_de_blah').and_return(double('MojoMagick::CommandStatus', return_value:"JPG 12 14 RGB"))
      MojoMagick.should_receive(:resize).and_raise
      File.should_receive(:open).with(full_destpath, 'wb').and_yield(writable)
      expect {
        image_file.save upload, destdir, destfile
      }.to raise_error MauImage::ImageError
    end

  end

end
