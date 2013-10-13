require 'spec_helper'

describe MainController do

  render_views
  fixtures :users, :artist_infos, :cms_documents, :studios
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
      ActiveRecord::Base.connection.execute("update artist_infos set open_studios_participation = '201210'")
      Artist.any_instance.stub(:in_the_mission? => true)
      @a = users(:artist1)
      @b = users(:joeblogs)
      get :openstudios
    end
    it_should_behave_like "a regular mobile page"
    it 'assigns participating studios with only studios that have os artists without studio = 0' do
      n = Artist.active.open_studios_participants.select{|a| !a.studio_id.nil? && a.studio_id != 0}.map(&:studio).uniq.count
      assigns(:participating_studios).should have(n).studios
    end
    it 'contains participant count for studios should be > 0' do
      assigns(:participating_studios).each do |s|
        s.artists.open_studios_participants.length.should > 0
      end
    end
    it 'assigns the right number of participating indies (all os participants with studio = 0)' do
      n = Artist.active.open_studios_participants.select{|a| a.studio_id == 0}.count
      n.should > 0
      assigns(:participating_indies).should have(n).artists
    end
    it "uses cms for parties" do
      CmsDocument.should_receive(:where).at_least(2).and_return([:os_blurb,:os_preview_reception].map{|k| cms_documents(k)})

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
    render_views
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
