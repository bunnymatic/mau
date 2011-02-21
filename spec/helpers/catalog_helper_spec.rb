require File.dirname(__FILE__) + "/../spec_helper"

describe 'catalog helper' do

  # lats 0, 1/4, 1/2, 3/4 and 4/4
  # 37.75032408	37.75464997	37.75897587	37.76330177	37.76762766
  # lngs 0, 1/4 1/2 3/4 and 4/4
  # -122.4265866	-122.4209982	-122.4154098	-122.4098213	-122.4042329
  describe 'compute position' do
    it "middle of a 100x100 map gives 50x50" do
      result = CatalogHelper::compute_position([100,100], 37.75897587, -122.4154098)
      result[0].should be_close 50, 0.02
      result[1].should be_close 50, 0.02
    end
    it "at 1/4 and 1/2 of a 100x100 map gives 25x50" do
      result = CatalogHelper::compute_position([100,100], 37.75464997, -122.4154098)
      result[0].should be_close 25, 0.02
      result[1].should be_close 50, 0.02
    end
    it "at 1/2 and 3/4 of a 100x100 map gives 50x75" do
      result = CatalogHelper::compute_position([100,100], 37.75897587, -122.4098213)
      result[0].should be_close 50, 0.02
      result[1].should be_close 75, 0.02
    end
    it "at 1/2 and 3/4 of a 200x100 map gives 100x75" do
      result = CatalogHelper::compute_position([200,100], 37.75897587, -122.4098213)
      result[0].should be_close 100, 0.02
      result[1].should be_close 75, 0.02
    end

  end
end
