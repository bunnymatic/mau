require 'spec_helper'

shared_examples_for ImageDimensions do
  before do
    subject.image_height = 500
    subject.image_width = 1500
  end

  describe 'compute_dimensions' do
    it 'computes proper dimension for a landscape image' do
      dims = subject.compute_dimensions
      dims[:thumb].should eql [100,33]
      dims[:small].should eql [200,66]
      dims[:medium].should eql [400,133]
      dims[:large].should eql [800,266]
      dims[:original].should eql [1500,500]
    end

    it 'computes proper dimension for a portrait image' do
      subject.image_height = 1500
      subject.image_width = 500
      dims = subject.compute_dimensions
      dims[:thumb].should eql [33,100]
      dims[:small].should eql [66,200]
      dims[:medium].should eql [133,400]
      dims[:large].should eql [266,800]
      dims[:original].should eql [500,1500]
    end

    it 'returns [0,0] if width is missing' do
      subject.image_width = nil
      dims = subject.compute_dimensions
      [:thumb, :small, :medium, :large].each do |k|
        dims[k].should eql [0,0]
      end
    end

    it 'returns [0,0] if height is missing' do
      subject.image_height = nil
      dims = subject.compute_dimensions
      [:thumb, :small, :medium, :large].each do |k|
        dims[k].should eql [0,0]
      end
    end
  end

  describe 'get_min_scaled_dimensions' do
    it 'computes proper dimension for a landscape image' do
      (subject.get_min_scaled_dimensions 50).should eql [150,50]
    end

    it 'computes proper dimension for a portrait image' do
      subject.image_height = 1500
      subject.image_width = 500
      (subject.get_min_scaled_dimensions 50).should eql [50,150]
    end

    it 'returns [50,50] if width is missing' do
      subject.image_width = nil
      (subject.get_min_scaled_dimensions 24).should eql [24,24]
    end

    it 'returns [50,50] if width is missing' do
      subject.image_height = nil
      (subject.get_min_scaled_dimensions 24).should eql [24,24]
    end
  end

end
