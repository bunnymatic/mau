require 'spec_helper'

describe ErrorController do
  before do
    get :index
  end

  it { response.status.should eql 400 }
  it { response.should render_template :mau1col }
end
