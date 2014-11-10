require 'spec_helper'

describe MainController do

  render_views
  describe "index" do
    before do
      get :index, :format => :mobile
    end
    it_should_behave_like "a regular mobile page"
    it "uses the welcome mobile layout" do
      expect(response).to render_template 'layouts/mobile_welcome'
    end
    it 'includes a menu with 6 items' do
      assert_select('ul li', :count => 6)
    end
    it "includes menu item for studios" do
      assert_select('ul li a[href="/studios/"]', :count => 1)
    end
    it "includes menu item for artists" do
      assert_select('ul li a[href="/artists/thumbs/"]', :count => 1)
    end
    it "includes menu item for about" do
      assert_select('ul li a[href="/open_studios/"]', :count => 1)
    end
  end

  describe 'open_studios' do
    before do
      docs = FactoryGirl.create_list(:cms_document,2, article: "# header\n\n## header2\n")
      CmsDocument.should_receive(:where).at_least(2).and_return docs
      get :open_studios, :format => :mobile
    end
    it_should_behave_like "a regular mobile page"

    it "uses cms for parties" do
      get :open_studios, :format => :mobile
    end
    it "renders the markdown version" do
      get :open_studios, :format => :mobile
      assert_select('h1', :match => 'header')
      assert_select('h2', :match => 'header2')
    end
  end

  describe "#news" do
    context "while not logged in" do
      before do
        FactoryGirl.create :cms_document, { 
          page: :main,
          section: :artist_resources,
          article: 'rock the house'
        }
        get :resources, :format => :mobile
      end
      it_should_behave_like 'returns success'
      it 'has the mobile content section' do
        assert_select 'div#open_studios[data-role=content]'
      end
      it 'has a markdown section' do
        assert_select '.section[data-cmsid]'
      end
      it "uses the welcome mobile layout" do
        expect(response).to render_template 'layouts/mobile_welcome'
      end
    end
  end

end
