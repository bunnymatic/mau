require 'spec_helper'

describe Api::V2::StudiosController do

  let(:studio) {create(:studio, :with_artists)}
  before do
    studio
  end

  describe "#show" do
    def make_request
      get :show, id: studio.slug
    end

    it "requires proper authorization"

  end

end
