require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeedsController do
  before do
    Rails.cache.stubs(:write => false, :delete => nil)
  end

end

