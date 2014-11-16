require 'spec_helper'

describe ErrorController do
  before do
    get :index
  end

  it { response.status.should eql 400 }
end
