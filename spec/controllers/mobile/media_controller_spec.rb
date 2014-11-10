require 'spec_helper'

describe MediaController do

  render_views

  let(:media) { FactoryGirl.create_list(:medium, 3) }
  let(:artists) { FactoryGirl.create_list(:artist, 2, :active) }
  let!(:art_pieces) {
    10.times.map { FactoryGirl.create(:art_piece, medium_id: media.sample.id, artist: artists.sample) }
  }

  before do
    # do mobile
    Artist.any_instance.stub(:os_participation => {'201104' => true})
    request.stub(:user_agent => IPHONE_USER_AGENT)
  end

  context "show" do
    before do
      get :show, :id => art_pieces.map(&:medium_id).compact.first, :format => :mobile
    end
    it_should_behave_like 'a regular mobile page'
    it_should_behave_like "non-welcome mobile page"
    it "returns success" do
      expect(response).to be_success
    end
    it "assigns artists" do
      assigns(:artists).should have_at_least(1).artist
    end
    it "assigns frequency" do
      assigns(:frequency).should have_at_least(1).item
    end
    it "assigns frequency correctly" do
      freq = assigns(:frequency)
      expect(freq.any?{|f| f['ct'] == 1.0}).to eql true
    end
    it 'artists list should not include duplicates' do
      assigns(:artists).uniq.count.should eql assigns(:artists).count
    end
  end
end
