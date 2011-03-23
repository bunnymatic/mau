specdir = File.expand_path(File.dirname(__FILE__)) + "/../../"

require specdir + 'spec_helper'
require specdir + 'mobile_shared_spec'

describe MainController do

  integrate_views
  fixtures :users, :artist_infos, :cms_documents, :studios
  before do
    # do mobile
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
  end

  describe "index" do
    before do
      get :index
    end
    it_should_behave_like "a regular mobile page"
    it "uses the welcome mobile layout" do
      response.layout.should == 'layouts/mobile_welcome'
    end
    it 'includes a menu with 2 items' do
      response.should have_tag('ul li', :count => 5)
    end
    it "includes menu item for studios" do
      response.should have_tag('ul li a[href="/studios/"]', :count => 1)
    end
    it "includes menu item for artists" do
      response.should have_tag('ul li a[href="/artists/thumbs/"]', :count => 1)
    end
    it "includes menu item for about" do
      response.should have_tag('ul li a[href="/openstudios/"]', :count => 1)
    end
  end
  describe 'openstudios' do
    before do
      ActiveRecord::Base.connection.execute("update artist_infos set open_studios_participation = '201104'")
      Artist.any_instance.stubs(:in_the_mission? => true)
      @a = users(:artist1)
      @ai = artist_infos(:artist1)
      @a.artist_info = @ai
      @a.save
      @s = studios(:s1890)
      @a.studio = @s
      @a.save
      
      @b = users(:joeblogs)
      @bi = artist_infos(:joeblogs)
      @b.artist_info = @bi
      @b.studio_id = 0
      @b.save

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
      CmsDocument.expects(:find_by_page_and_section).with('main_openstudios','preview_reception').returns(cms_documents(:preview_reception))
      get :openstudios
    end
    it "renders the markdown version" do
      CmsDocument.any_instance.stubs(:article => <<EOM
# header

## header2 

stuff
EOM
                                     )
      
      get :openstudios
      response.should have_tag('h1', :match => 'header')
      response.should have_tag('h2', :match => 'header2')
      response.should have_tag('p', :match => 'stuff')
    end
  end
end
