require 'spec_helper'

describe MainController do

  render_views
  fixtures :cms_documents
  before do
    # do mobile
    request.stub(:user_agent => IPHONE_USER_AGENT)
  end

  describe "index" do
    before do
      get :index
    end
    it_should_behave_like "a regular mobile page"
    it "uses the welcome mobile layout" do
      response.should render_template 'layouts/mobile_welcome'
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
      assert_select('ul li a[href="/openstudios/"]', :count => 1)
    end
  end

  describe 'openstudios' do
    before do
      get :openstudios
    end
    it_should_behave_like "a regular mobile page"

    it "uses cms for parties" do
      docs = [:os_blurb,:os_preview_reception].map{|k| cms_documents(k)}
      CmsDocument.should_receive(:where).at_least(2).and_return(docs)

      get :openstudios
    end
    it "renders the markdown version" do
      CmsDocument.any_instance.stub(:article => <<EOM
# header

## header2

stuff
EOM
                                     )

      get :openstudios
      assert_select('h1', :match => 'header')
      assert_select('h2', :match => 'header2')
      assert_select('p', :match => 'stuff')
    end
  end

  describe "#news" do
    context "while not logged in" do
      before do
        get :resources
      end
      it_should_behave_like 'returns success'
      it 'has the mobile content section' do
        assert_select 'div#open_studios[data-role=content]'
      end
      it 'has a markdown section' do
        assert_select '.section[data-cmsid]'
      end
      it "uses the welcome mobile layout" do
        response.should render_template 'layouts/mobile_welcome'
      end
    end
  end

end
