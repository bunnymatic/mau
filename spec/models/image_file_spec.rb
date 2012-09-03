require 'spec_helper'


describe ImageFile do

  it 'sizes includes height and width and extension for all sizes' do
    ImageFile.sizes.keys.each do |sz_key|
      [:h, :w, :ext].each do |key|
        ImageFile.sizes[sz_key].keys.should include key
      end
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


end
