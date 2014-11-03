# helper methods for controllers testing

def get_all_actions(cont)
  c= Module.const_get(cont.to_s.pluralize.capitalize + "Controller")
  c.public_instance_methods(false).reject{ |action| ['rescue_action'].include?(action) || action.match(/^_/)}
end

# test actions fail if not logged in
# opts[:exclude] contains an array of actions to skip
# opts[:include] contains an array of actions to add to the test in addition
# to any found by get_all_actions
def controller_actions_should_fail_if_not_logged_in(cont, opts={})
  except= opts[:except] || []
  excepts = except.map { |ex| ex.to_s }
  actions_to_test = get_all_actions(cont).reject{ |a| excepts.include?(a.to_s) }
  actions_to_test += opts[:include] if opts[:include]
  actions_to_test.each do |a|
    get a
    expect(response).to redirect_to( new_user_session_path ), "Incorrect redirect on action [#{a}]"
  end
end

# logged in - get edit page
shared_examples_for "logged in edit page" do
  it "has at least open-close divs with edit, notification, password, links and deactivation section" do
    assert_select('.open-close-div.acct')
    assert_select('.open-close-div #info_toggle')
    assert_select('#info')
    assert_select('.open-close-div #notifications_toggle')
    assert_select('#notifications')
    assert_select('form[action=/change_password_update]')
    assert_select('#passwd')
    assert_select('#deactivate')
    assert_select('.open-close-div #links_toggle')
    assert_select('#links')
  end
end

# for all
shared_examples_for "logged in user" do
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
    if @logged_in_user.is_a? Artist
      assert_select "#osnav .dir .leaf a[href=#{edit_artist_path(@logged_in_user)}#events]"
    else
      assert_select "#osnav .dir .leaf a[href=#{login_path}]"
    end
  end
end

shared_examples_for 'logged in artist' do
  describe "nav" do
    it 'has a nav bar with artist links' do
      assert_select('#nav_bar')
      assert_select("#mymaunav li.dir a[href=#{artist_path(@logged_in_artist)}]", 'my&nbsp;mau')
      assert_select('#mymaunav li.dir ul li.leaf', :minimum => 5)
      assert_select("#mymaunav li.leaf a[href=#{edit_artist_path(@logged_in_artist)}]")
      assert_select("#mymaunav li.leaf a[href=#{arrange_art_artists_path}]")
      assert_select("#mymaunav li.leaf a[href=#{delete_art_artists_path}]")
      assert_select("#mymaunav li.leaf a[href=#{favorites_user_path(@logged_in_artist)}]")
    end
  end
end

shared_examples_for "logged in as editor" do
  it "shows a link to the dashboard" do
    assert_select("#admin_nav a.lkdark[href=#{admin_path}]", 'dashboard')
  end
end

shared_examples_for "logged in as admin" do
  it_should_behave_like 'logged in as editor'

  it "shows the admin bar with admin links" do
    assert_select("#admin_nav")
    %w{ roles os_status featured_artist favorites artists studios fans media events }.each do |admin_link|
      assert_select "#admin_nav a.lkdark[href=/admin/#{admin_link}]", admin_link.humanize.downcase
    end
  end

end

shared_examples_for 'login required' do
  it "redirects to login" do
    expect(response).to redirect_to(new_user_session_path)
  end
end

shared_examples_for "redirects to login" do
  it_should_behave_like 'login required'
end

shared_examples_for "not logged in" do
  it 'header includes login, signup and artists nav with links to tag/media search' do
    assert_select("#login_toplink a[href=/login]", :include_text => "join in")
    assert_select("#login_toplink a[href=/signup]")
    assert_select("ul#artistsnav")
    assert_select("ul#artistsnav .leaf a[href=#{media_path :m => 'a'}]")
    assert_select("ul#artistsnav .leaf a[href=#{art_piece_tags_path :m => 'a'}]")
  end

  context 'open studios section' do
    it 'renders open studios links' do
      assert_select "ul#osnav .dir a[href=#{open_studios_path}]"
      assert_select "ul#osnav ul li.leaf a[href=#{artists_path(:osonly => 1)}]"
      assert_select "ul#osnav ul li.leaf a[href=#{map_artists_path(:osonly => 1)}]"
      assert_select "ul#osnav ul li.leaf a[href=#{login_path}]"
      assert_select "ul#osnav ul li.leaf a[href=/resources]"
    end
  end

  context 'studios section' do
    it 'renders studio related links' do
      assert_select "ul#studionav .dir a[href=#{studios_path}]", 'spaces'
      assert_select "ul#studionav ul li.leaf a[href=#{studios_path}]"
      assert_select "ul#studionav ul li.leaf a[href=#{studio_path(0)}]"
      assert_select "ul#studionav ul li.leaf a[href=#{venues_path}]"
    end
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
    new_art.sort_by(&:created_at).reverse.map(&:id).should == new_art.map(&:id)
  end
  it 'has all the action buttons' do
    ct = (Time.zone.now > Time.utc(2012,3,12)) ? 3 : 4
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

shared_examples_for 'renders error page' do
  it "renders an error page" do
    expect(response).to render_template 'error/index'
  end
  it "show a 404" do
    expect(response.code).to eql '404'
  end

end

shared_examples_for "not authorized" do
  it "redirects to error page" do
    expect(response).to redirect_to error_path
  end
end

shared_examples_for 'returns success' do
  it { expect(response).to be_success }
end

shared_examples_for 'successful json' do
  it { expect(response).to be_success }
  it { expect(response).to be_json }
end

