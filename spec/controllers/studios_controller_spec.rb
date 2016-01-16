require 'rails_helper'

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
        expect(j.count).to eql assigns(:studio_list).count
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

    describe 'unknown studio' do
      before do
        get :show, "id" => 'blurp'
      end
      it {expect(response).to redirect_to studios_path}
      it 'sets the flash' do
        expect(flash[:error]).to be_present
      end
    end

    describe 'individual studio' do
      describe 'html' do
        before do
          allow_any_instance_of(Studio).to receive(:phone).and_return('1234569999')
          allow_any_instance_of(Studio).to receive(:cross_street).and_return('fillmore')
          get :show, id: studio.slug, format: 'html'
        end
        it {expect(response).to be_success}
      end

      describe 'json' do
        context 'non indy studio' do
          before do
            get :show, id: studio.id, format: 'json'
          end
          it_should_behave_like 'successful json'
          it 'returns the studio data' do
            j = JSON.parse(response.body)
            expect(j['studio']['name']).to eql studio.name
            expect(j['studio']['street_address']).to eql studio.street
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
          expect(j['studio']['name']).to eql "Independent Studios"
        end
      end
    end
  end

end
