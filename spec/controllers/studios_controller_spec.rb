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

    context "while not logged in" do
      context 'default mode' do
        before do
          get :index
        end
        it_should_behave_like "not logged in"
        it "last studio should be independent studios" do
          assigns(:studios).studios.last.name.should eql 'Independent Studios'
        end

        it "sets view_mode to name" do
          assigns(:view_mode).should eql 'name'
        end
      end
      context "with view mode set to count" do
        before do
          get :index, :v => 'c'
        end
        it "sets view_mode to count" do
          assigns(:view_mode).should eql 'count'
        end
      end
    end
    context "while logged in as an art fan" do
      before do
        login_as fan
        get :index
      end
      it_should_behave_like "logged in user"
    end
    describe 'json' do
      before do
        get :index, :format => 'json'
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

    describe 'indy studio' do
      before do
        get :show, "id" => 0
      end
      it "sets the studio to the indy studio" do
        assigns(:studio).studio.name.should eql "Independent Studios"
      end
    end

    describe 'individual studio' do
      describe 'html' do
        before do
          Studio.any_instance.stub(:phone => '1234569999')
          Studio.any_instance.stub(:cross_street => 'fillmore')
          get :show, "id" => studio
        end
        it "last studio should be independent studios" do
          assigns(:studios).last.name.should eql 'Independent Studios'
        end
        it "studios are in alpha order by our fancy sorter (ignoring the) with independent studios at the end" do
          s = assigns(:studios)
          s.pop
          def prep_name(a)
            a.name.downcase.gsub(/^the\ /, '')
          end

          s.sort_by{|a| prep_name(a)}.map(&:name).should eql s.map(&:name)
        end
        it "studio url is a link" do
          assert_select("div.url a[href=#{studio.url}]")
        end
        it "studio includes cross street if there is one" do
          assert_select('.address', /\s+fillmore/)
        end
        it "studio info includes a phone if there is one" do
          assert_select('.phone', :text => '(123) 456-9999')
        end
      end

      describe 'json' do
        before do
          get :show, :id => studio.id, :format => 'json'
        end
        it_should_behave_like 'successful json'
        it 'returns the studio data' do
          j = JSON.parse(response.body)
          j['studio']['name'].should eql studio.name
          j['studio']['street'].should eql studio.street
        end
        it 'includes a list of artist ids' do
          j = JSON.parse(response.body)
          j['studio']['artists'].should be_a_kind_of Array
        end
      end
    end
  end

end
