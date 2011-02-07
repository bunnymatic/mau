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
describe "logged in edit page", :shared => true do
  before do
    get :edit
  end
  it "has at least 6 open-close divs" do
    response.should have_tag('.open-close-div.acct:nth-child(6)') 
  end
  it "has the info edit section" do
    response.should have_tag('.open-close-div #info_toggle')
    response.should have_tag('#info')
  end
  it "has the notification section" do
    response.should have_tag('.open-close-div #notification_toggle')
    response.should have_tag('#notification')
  end
  it "has the change password section" do
    response.should have_tag('form[action=/change_password_update]')
    response.should have_tag('#passwd')
  end
  it "has the deactivate section" do
    response.should have_tag('#deactivate')
  end
  it "has the links edit section" do
    response.should have_tag('.open-close-div #links_toggle')
    response.should have_tag('#links')
  end
end

# for all
describe "logged in user", :shared => true do
  it "header bar should say hello" do
    response.should have_tag("span.logout-nav", :text => /hello/)
  end
  it "header bar should have my login name as a link" do
    if @logged_in_user.type == "Artist"
      response.should have_tag("span.logout-nav a", :text => @logged_in_user.login)
    else 
      response.should have_tag("span.logout-nav ", :text => /#{@logged_in_user.login}/)
    end
  end
  it "header bar should have logout tag" do
    response.should have_tag("span.last a[href=/logout]");
  end
end

describe 'logged in artist', :shared => true do
  describe "nav" do
    it 'has a nav bar' do
      response.should have_tag('#nav_bar')
    end
    it 'has a my mau link' do
      response.should have_tag("#mymaunav li.dir a[href=#{artist_path(@logged_in_artist)}]", 'my&nbsp;mau')
    end
    it 'my mau link has 5 subnodes' do
      response.should have_tag('#mymaunav li.dir ul li.leaf', :count => 5)
    end
    it 'has edit link' do
      response.should have_tag("#mymaunav li.leaf a[href=#{edit_artist_path(@logged_in_artist)}]")
    end
    it 'has arrange art link' do
      response.should have_tag("#mymaunav li.leaf a[href=#{arrangeart_artists_path}]")
    end
    it 'has delete art link' do
      response.should have_tag("#mymaunav li.leaf a[href=#{deleteart_artists_path}]")
    end
    it 'has my favorites link' do
      response.should have_tag("#mymaunav li.leaf a[href=#{favorites_user_path(@logged_in_artist)}]")
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

describe "not logged in", :shared => true do
  it "header bar should have login link" do
    response.should have_tag("#login_toplink a[href=/login]")
  end
  it "header bar should have signup link" do
    response.should have_tag("#login_toplink a[href=/signup]")
  end
  it "header has artists section" do 
    response.should have_tag("ul#artistsnav")
  end
  it "artists section has by tag and by medium" do
    response.should have_tag("ul#artistsnav .leaf a[href=#{media_path :m => 'a'}]")
    response.should have_tag("ul#artistsnav .leaf a[href=#{art_piece_tags_path :m => 'a'}]")
  end
  it "nav bar suggests join in" do 
    response.should have_tag("div ul#mymaunav li.dir a[href=/login]", :include_text => "join in")
  end
  
end


