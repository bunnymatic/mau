# helper methods for controllers testing

def get_all_actions(cont)
  c= Module.const_get(cont.to_s.pluralize.capitalize + "Controller")
  c.public_instance_methods(false).reject{ |action| ['rescue_action'].include?(action) }
end

# test actions fail if not logged in
# opts[:exclude] contains an array of actions to skip
# opts[:include] contains an array of actions to add to the test in addition
# to any found by get_all_actions
def controller_actions_should_fail_if_not_logged_in(cont, opts={})
  except= opts[:except] || []
  excepts = except.map { |ex| ex.to_s }
  actions_to_test= get_all_actions(cont).reject{ |a| excepts.include?(a) }
  actions_to_test += opts[:include] if opts[:include]
  actions_to_test.each do |a|
    get a
    response.should redirect_to( new_session_path ), "Incorrect redirect on action [#{a}]"
  end
end


def response_should_be_json
  Mime::Type.lookup(response.content_type).to_sym.should eql :json
end

# logged in - get edit page 
shared_examples_for"logged in edit page" do
  before do
    get :edit
  end
  it "has at least 6 open-close divs" do
    assert_select('.open-close-div.acct:nth-child(6)') 
  end
  it "has the info edit section" do
    assert_select('.open-close-div #info_toggle')
    assert_select('#info')
  end
  it "has the notification section" do
    assert_select('.open-close-div #notification_toggle')
    assert_select('#notification')
  end
  it "has the change password section" do
    assert_select('form[action=/change_password_update]')
    assert_select('#passwd')
  end
  it "has the deactivate section" do
    assert_select('#deactivate')
  end
  it "has the links edit section" do
    assert_select('.open-close-div #links_toggle')
    assert_select('#links')
  end
end

# for all
describe "logged in user", :shared => true do
  it "header bar should say hello" do
    assert_select("span.logout-nav", :text => /hello/)
  end
  it "header bar should have my login name as a link" do
    if @logged_in_user.type == "Artist"
      assert_select("span.logout-nav a", :text => @logged_in_user.login)
    else 
      assert_select("span.logout-nav ", :text => /#{@logged_in_user.login}/)
    end
  end
  it "header bar should have logout tag" do
    assert_select("span.last a[href=/logout]");
  end
  it 'has link to signup for os' do
    assert_select "#osnav .dir .leaf a[href=#{edit_artist_path(@logged_in_user)}#events]"
  end
end

describe 'logged in artist', :shared => true do
  describe "nav" do
    it 'has a nav bar' do
      assert_select('#nav_bar')
    end
    it 'has a my mau link' do
      assert_select("#mymaunav li.dir a[href=#{artist_path(@logged_in_artist)}]", 'my&nbsp;mau')
    end
    it 'my mau link has at least 5 subnodes' do
      assert_select('#mymaunav li.dir ul li.leaf', :minimum => 5)
    end
    it 'has edit link' do
      assert_select("#mymaunav li.leaf a[href=#{edit_artist_path(@logged_in_artist)}]")
    end
    it 'has arrange art link' do
      assert_select("#mymaunav li.leaf a[href=#{arrangeart_artists_path}]")
    end
    it 'has delete art link' do
      assert_select("#mymaunav li.leaf a[href=#{deleteart_artists_path}]")
    end
    it 'has my favorites link' do
      assert_select("#mymaunav li.leaf a[href=#{favorites_user_path(@logged_in_artist)}]")
    end
  end
end

shared_examples_for "logged in as editor" do
  it 'includes the editor javascript' do
    assert_select('script[src^=/javascripts/mau/mau_editor.js]')
  end
end

shared_examples_for "logged in as admin" do
  it_should_behave_like 'logged in as editor'
  it 'includes the editor javascript' do
    assert_select('script[src^=/javascripts/mau/mau_editor.js]')
  end
  it "shows the admin bar" do
    assert_select("#admin_nav")
  end
  it "shows a link to the dashboard" do
    assert_select('#admin_nav a.lkdark[href=/admin]', 'dashboard')
  end
  
  %w{ os_status featured_artist favorites artists studios fans media roles events }.each do |admin_link|
    it ("shows a link to admin/%s" % admin_link) do
      assert_select('#admin_nav a.lkdark[href=/admin/'+admin_link+']', admin_link)
    end
  end
 
end

describe "redirects to login", :shared => true do 
  it "redirects to login" do
    response.should redirect_to(new_session_path)
  end
end

describe "get/post update redirects to login", :shared => true do
  describe "get update" do
    before do
      get :update
    end
    it_should_behave_like "redirects to login"
  end
  describe "post update" do
    before do
      post :update
    end
    it_should_behave_like "redirects to login"
  end
end

shared_examples_for "not logged in" do
  it "header bar should have login link" do
    assert_select("#login_toplink a[href=/login]")
  end
  it "header bar should have signup link" do
    assert_select("#login_toplink a[href=/signup]")
  end
  it "header has artists section" do 
    assert_select("ul#artistsnav")
  end
  it "artists section has by tag and by medium" do
    assert_select("ul#artistsnav .leaf a[href=#{media_path :m => 'a'}]")
    assert_select("ul#artistsnav .leaf a[href=#{art_piece_tags_path :m => 'a'}]")
  end
  context 'open studios section' do
    it 'renders open studios link' do
      assert_select "ul#osnav .dir a[href=#{openstudios_path}]"
    end
    it 'renders a link to open studios participants' do
      assert_select "ul#osnav ul li.leaf a[href=#{artists_path(:osonly => 1)}]"
    end
    it 'renders a link to open studios map' do
      assert_select "ul#osnav ul li.leaf a[href=#{map_artists_path(:osonly => 1)}]"
    end
    it 'renders a link to plug your event' do
      assert_select "ul#osnav ul li.leaf a[href=#{login_path}]"
    end
    it 'renders a link to resources' do
      assert_select "ul#osnav ul li.leaf a[href=/resources]"
    end
  end

  context 'studios section' do
    it 'renders studios link' do
      assert_select "ul#studionav .dir a[href=#{studios_path}]", 'spaces'
    end
    it 'renders a link to group studios' do
      assert_select "ul#studionav ul li.leaf a[href=#{studios_path}]"
    end
    it 'renders a link to indy studios' do
      assert_select "ul#studionav ul li.leaf a[href=#{studio_path(0)}]"
    end
    it 'renders a link to venues' do
      assert_select "ul#studionav ul li.leaf a[href=#{venues_path}]"
    end
  end

  it "nav bar suggests join in" do 
    assert_select("div ul#mymaunav li.dir a[href=/login]", :include_text => "join in")
  end
  
end

shared_examples_for 'standard sidebar layout' do
  it_should_behave_like 'two column layout'
  it 'has a new art sidebar element' do
    assert_select '.lcol .new_art'
  end
  it 'assigns new art sorted by created at' do
    new_art = assigns(:new_art)
    new_art.should be_present
    new_art.sort_by(&:created_at).reverse.should == new_art
  end
  it 'has all the action buttons' do
    ct = (Time.now > Time.utc(2012,3,12)) ? 4 : 5
    assert_select '.action_button', :count => ct
  end
end

shared_examples_for 'two column layout' do
  it 'has a two column body class' do
    assert_select('body.two_column')
  end
end
shared_examples_for 'one column layout' do
  it 'has a one column body class' do
    assert_select('body.one_column')
  end
end

describe "not authorized", :shared => true do
  it "redirects to error page" do
    response.should redirect_to 'error'
  end
end

shared_examples_for 'returns success' do
  it 'returns success' do
    response.should be_success
  end
end
