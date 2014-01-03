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

  describe ImageFile::ImageSizes do
    describe '#height' do
      it 'returns height for small' do
        ImageFile::ImageSizes.height(:small).should eql 200
      end
      it 'returns height for l' do
        ImageFile::ImageSizes.height('l').should eql 800
      end
      it 'returns nil for orig' do
        ImageFile::ImageSizes.height('orig').should be_nil
      end
      it 'returns 400 for unknown' do
        ImageFile::ImageSizes.height('unk').should eql 400
      end
    end

    describe '#width' do
      it 'returns width for small' do
        ImageFile::ImageSizes.width(:small).should eql 200
      end
      it 'returns width for l' do
        ImageFile::ImageSizes.width('l').should eql 800
      end
      it 'returns nil for orig' do
        ImageFile::ImageSizes.width('orig').should be_nil
      end
      it 'returns 400 for unknown' do
        ImageFile::ImageSizes.width('unk').should eql 400
      end
    end

    describe '#keymap' do
      it 'returns medium given nothing' do
        ImageFile::ImageSizes.keymap(nil).should eql :medium
        ImageFile::ImageSizes.keymap('').should eql :medium
      end
      it 'returns original for "orig"' do
        ImageFile::ImageSizes.keymap('orig').should eql :original
        ImageFile::ImageSizes.keymap(:orig).should eql :original
      end
      it 'returns thumb for thumbnail & thumb' do
        %w(thumb thumbnail).each do |sz|
          ImageFile::ImageSizes.keymap(sz).should eql :thumb
          ImageFile::ImageSizes.keymap(sz.to_sym).should eql :thumb
        end
      end
      it 'returns small for s or sm' do
        %w(s sm).each do |sz|
          ImageFile::ImageSizes.keymap(sz).should eql :small
          ImageFile::ImageSizes.keymap(sz.to_sym).should eql :small
        end
      end
      it 'returns large for l' do
        ImageFile::ImageSizes.keymap('l').should eql :large
        ImageFile::ImageSizes.keymap(:l).should eql :large
      end
      it 'returns medium for m, med, standard, std or medium' do
        %w(m med standard std medium).each do |sz|
          ImageFile::ImageSizes.keymap(sz).should eql :medium
        end
      end
      it 'returns the medium for something it doesn\'t recognize' do
        ImageFile::ImageSizes.keymap('blow').should eql :medium
        ImageFile::ImageSizes.keymap(:blow).should eql :medium
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

  describe "#save" do
    let (:writable) { double('Writable',:write => nil) }
    let (:upload) { {'datafile' => double('Uploadable', :read => '', :original_filename => 'uploaded_file.jpg') } }
    let (:destdir) { 'destination/directory'}
    let (:destfile) { 'destfile.file' }
    let (:full_destpath) { File.join(destdir, destfile) }
    subject(:image_file) { ImageFile.new(upload, destdir, destfile) }

    before do
      Pathname.stub(:new => double("Path", :realpath => 'blah_de_blah'))
    end

    it 'disallows CMYK format' do
      MojoMagick.should_receive(:raw_command).
        with('identify', '-format "%m %h %w %r" ' + 'blah_de_blah').and_return("JPG 12 14 CMYK")
      File.should_receive(:open).with(full_destpath, 'wb').and_yield(writable)
      expect {
        image_file.save
      }.to raise_error ArgumentError
    end

    it 'sets up the right path name and calls resize for all the desired sizes' do
      MojoMagick.stub(:raw_command)
      MojoMagick.should_receive(:raw_command).
        with('identify', '-format "%m %h %w %r" ' + 'blah_de_blah').and_return("JPG 12 14 RGB")
      MojoMagick.should_receive(:resize).exactly(4).times
      File.should_receive(:open).with(full_destpath, 'wb').and_yield(writable)
      image_file.save
    end

    it 'sizes respond to height and width and prefix for all sizes' do
      image_file.sizes.keys.each do |sz_key|
        [:height, :width, :prefix].each do |key|
          image_file.sizes[sz_key].should respond_to key
        end
      end
    end

  end

end
