require 'rails_helper'

describe ImageFile do
  %w[original orig].each do |size|
    it "get_path for #{size} returns a file name with no prefix" do
      fname = ImageFile.get_path('dir', size, 'myfile.jpg')
      expect(fname).to match(%r{dir/myfile\.jpg$})
    end
  end
  ['large'].each do |size|
    it "get_path for #{size} returns a file name with l_ as a prefix" do
      fname = ImageFile.get_path('dir', size, 'myfile.jpg')
      expect(fname).to match(%r{dir/l_myfile\.jpg$})
    end
  end
  %w[medium standard].each do |size|
    it "get_path for #{size} returns a file name with m_ as a prefix" do
      fname = ImageFile.get_path('dir', size, 'myfile.jpg')
      expect(fname).to match(%r{dir/m_myfile\.jpg$})
    end
  end

  describe '#get_path' do
    let(:directory) { Faker::Files.dir }
    let(:file) { Faker::Files.file }
    it 'returns the right path where size is small' do
      expect(ImageFile.get_path(directory, :small, file)).to eql([directory, "s_#{file}"].join('/'))
    end
    it 'returns the right path where size is medium' do
      expect(ImageFile.get_path(directory, :medium, file)).to eql([directory, "m_#{file}"].join('/'))
    end
    it 'returns the right path where size is large' do
      expect(ImageFile.get_path(directory, :large, file)).to eql([directory, "l_#{file}"].join('/'))
    end
    it 'returns the right path where size is original' do
      expect(ImageFile.get_path(directory, :original, file)).to eql([directory, file].join('/'))
    end
  end
end
