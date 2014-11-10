require 'spec_helper'

describe Studio do

  subject(:studio) { FactoryGirl.build(:studio) }

  it_should_behave_like AddressMixin

  it { should validate_presence_of(:name) }

  describe 'address' do
    it "responds to address" do
      expect(studio).to respond_to :address
    end
    it "responds to full address" do
      expect(studio).to respond_to :full_address
    end
    it "responds to address_hash" do
      expect(studio).to respond_to :address_hash
    end
  end

  describe 'create' do
    let(:studio) { FactoryGirl.build(:studio) }
    before do
      @s = Studio.new(FactoryGirl.attributes_for(:studio))
    end
    it "studio is valid" do
      @s.should_receive(:compute_geocode).at_least(:once).and_return([-37,122])
      @s.should be_valid
    end
    it "save triggers geocode" do
      s = Studio.new(FactoryGirl.attributes_for(:studio))
      s.should_receive(:compute_geocode).at_least(:once).and_return([-37,122])
      s.save!
    end
  end

  describe 'update' do
    before do
      studio.save
    end

    it "triggers geocode given new street" do
      studio.street = '1891 Bryant St'
      studio.should_receive(:compute_geocode).at_least(:once).and_return([-37,122])
      studio.save!
    end
  end

  describe 'formatted_phone' do
    it "returns nicely formatted phone #" do
      studio.should_receive(:phone).and_return('4156171234')
      studio.formatted_phone.should eql '(415) 617-1234'
    end
  end

  describe 'to_json' do
    [:created_at, :updated_at].each do |field|
      it "does not include #{field} by default" do
        JSON.parse(studio.to_json)['studio'].should_not have_key field.to_s
      end
    end
    it "includes name" do
      JSON.parse(studio.to_json)['studio']['name'].should eql studio.name
    end
    it 'includes created_at if we except other fields' do
      s = JSON.parse(studio.to_json(:except => :name))
      s['studio'].should have_key 'created_at'
      s['studio'].should_not have_key 'name'
    end
    it 'includes the artist list if we ask for it' do
      a = FactoryGirl.create(:artist, :active, :with_studio)
      studio = a.studio
      s = JSON.parse(studio.to_json methods: 'artists')
      s['studio']['artists'].should be_a_kind_of Array
      s['studio']['artists'][0]['artist']['firstname'].should eql studio.artists.first.firstname
    end
  end
end
