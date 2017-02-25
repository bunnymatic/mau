# frozen_string_literal: true
require 'rails_helper'

describe ErrorController do
  before do
    get :index
  end

  it { expect(response.status).to eql 400 }
end
