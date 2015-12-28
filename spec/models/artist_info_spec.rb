require 'spec_helper'


describe ArtistInfo do

  it_should_behave_like AddressMixin

  let!(:open_studios_event) { FactoryGirl.create(:open_studios_event) }
  let(:joeblogs) { FactoryGirl.build(:artist_info, street: '1891 Bryant St') }
  let(:artist_info) { FactoryGirl.build(:artist_info) }

  describe 'address mixin' do
    it "responds to address" do
      expect(artist_info).to respond_to :address
    end
    it "responds to address_hash" do
      expect(artist_info).to respond_to :address_hash
    end
    it "responds to full_address" do
      expect(artist_info).to respond_to :full_address
    end
  end

  describe 'create' do
    describe "with valid attrs" do
      it "artist_info is valid" do
        expect(artist_info).to receive(:compute_geocode).and_return([-37,122])
        expect(artist_info).to be_valid
      end
      it "save triggers geocode" do
        expect(artist_info).to receive(:compute_geocode).and_return([-37,122])
        artist_info.save
      end
    end
  end

  describe 'save' do
    it "triggers geocode given new street" do
      expect(joeblogs).to receive(:compute_geocode).at_least(1).and_return([-37,122])
      joeblogs.save
    end
  end

  describe "open studios participation" do
    before do
      allow(joeblogs).to receive(:compute_geocode).at_least(1).and_return([-37,122])
      joeblogs.save!
    end

    describe 'get' do
      it "returns true if participation is 'true'" do
        expect(joeblogs).to receive('open_studios_participation').at_least(:once).and_return('date|other')
        expect(joeblogs.os_participation['date']).to be_true
      end
      it "returns nil if participation is missing" do
        expect(joeblogs).to receive('open_studios_participation').at_least(:once).and_return('date|something')
        expect(joeblogs.os_participation['other']).to be_nil
      end
    end

    describe 'add entry' do
      it "adding with = given = { '201104' => true } sets os_participation['201104']" do
        joeblogs.send(:os_participation=, { '201104' => true })
        joeblogs.reload
        expect(joeblogs.os_participation['201104']).to eql true
      end
      it "adding with update_os_participation[ '201104', true] sets os_participation['201104']" do
        joeblogs.update_os_participation('201104', true)
        joeblogs.save
        joeblogs.reload
        expect(joeblogs.os_participation['201104']).to eql true
      end
    end
    describe 'update' do
      before do
        joeblogs.open_studios_participation = '201104'
      end
      it "sets false using = {'201104',false}" do
        joeblogs.send(:os_participation=, {'201104' => false})
        joeblogs.reload
        expect(joeblogs.os_participation['201104']).to be_nil
      end
      it "sets false given update('201104',false)" do
        joeblogs.update_os_participation('201104', false)
        joeblogs.save
        joeblogs.reload
        expect(joeblogs.os_participation['201104']).to be_nil
      end
      it 'adds another key properly using update' do
        joeblogs.update_attribute(:open_studios_participation,'201104')
        joeblogs.update_os_participation('201114', true)
        joeblogs.reload
        expect(joeblogs.os_participation['201114']).to be_true
        expect(joeblogs.os_participation['201104']).to be_true
      end
      it 'adds another key properly using =' do
        joeblogs.update_attribute(:open_studios_participation,'201104')
        joeblogs.send(:os_participation=, {'201204' => true })
        joeblogs.reload
        expect(joeblogs.os_participation['201204']).to be_true
        expect(joeblogs.os_participation['201104']).to be_true
      end
    end
  end

end
