require 'spec_helper'

describe StudiosController do

  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:manager) { FactoryGirl.create(:artist, :with_studio, :manager) }
  let(:indy_artist) { FactoryGirl.create(:artist, :active) }
  let(:artist) { FactoryGirl.create(:artist, :with_studio, :active) }
  let(:manager_studio) { manager.studio }
  let(:studio) { manager.studio }

  let!(:studios) { [manager, indy_artist, artist].map{|a| a.studio} }

  describe "#index" do
    render_views

    describe 'json' do
      before do
        get :index, format: 'json'
      end
      it_should_behave_like 'successful json'
      it 'returns all studios' do
        j = JSON.parse(response.body)
        j.count.should eql assigns(:studio_list).count
      end
    end
  end

  describe "#show" do
    it 'gets independent studio with the slug' do
      get :show, id: 'independent-studios'
      expect(assigns(:studio).name).to eql "Independent Studios"
    end
  end

  describe "#show" do
    render_views

    describe 'unknown studio' do
      before do
        get :show, "id" => 'blurp'
      end
      it {expect(response).to redirect_to studios_path}
      it 'sets the flash' do
        flash[:error].should be_present
      end
    end

    describe 'individual studio' do
      describe 'html' do
        before do
          Studio.any_instance.stub(phone: '1234569999')
          Studio.any_instance.stub(cross_street: 'fillmore')
          get :show, id: studio.slug, format: 'html'
        end
        it "studio url is a link" do
          assert_select(".studio__website a[href=#{studio.url}]")
        end
        it "studio includes cross street if there is one" do
          assert_select('.studio-address', /\s+fillmore/)
        end
        it "studio info includes a phone if there is one" do
          assert_select('.studio-phone', text: '(123) 456-9999')
        end
      end

      describe 'json' do
        context 'non indy studio' do
          before do
            get :show, id: studio.id, format: 'json'
          end
          it_should_behave_like 'successful json'
          it 'returns the studio data' do
            j = JSON.parse(response.body)
            j['studio']['name'].should eql studio.name
            j['studio']['street_address'].should eql studio.street
          end
        end
      end
      context 'for indy studio' do
        before do
          get :show, id: 'independent-studios', format: 'json'
        end
        it_should_behave_like 'successful json'
        it 'returns the studio data' do
          j = JSON.parse(response.body)
          j['studio']['name'].should eql "Independent Studios"
        end
      end
    end
  end

end
