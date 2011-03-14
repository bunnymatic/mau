require File.dirname(__FILE__) + "/../spec_helper"

describe 'catalog helper' do

  # lats 0, 1/4, 1/2, 3/4 and 4/4
  # 37.75008655	37.75450575	37.75892495	37.76334416	37.76776336
  # lngs 0, 1/4 1/2 3/4 and 4/4
  # -122.42721	-122.4215455	-122.4158809	-122.4102164	-122.4045518
  describe 'compute position' do
    it "middle of a 100x100 map gives 50x50" do
      pending
      result = CatalogHelper::compute_position([100,100], 37.75892495, -122.4158809)
      result[0].should be_close 50, 0.02
      result[1].should be_close 50, 0.02
    end
    it "at 1/4 and 1/2 of a 100x100 map gives 25x50" do
      pending
      result = CatalogHelper::compute_position([100,100], 37.75450575, -122.4158809)
      result[0].should be_close 25, 0.02
      result[1].should be_close 50, 0.02
    end
    it "at 1/2 and 3/4 of a 100x100 map gives 50x75" do
      pending
      result = CatalogHelper::compute_position([100,100], 37.75892495, -122.4102614)
      result[0].should be_close 50, 0.02
      result[1].should be_close 75, 0.02
    end
    it "at 1/2 and 3/4 of a 200x100 map gives 100x75" do
      pending
      result = CatalogHelper::compute_position([200,100], 37.75892495, -122.4102614)
      result[0].should be_close 100, 0.02
      result[1].should be_close 75, 0.02
    end

  end
end
