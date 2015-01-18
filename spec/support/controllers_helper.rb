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
  it "header bar should say hello with login and logout and signup links as appopriate" do 
    assert_select("a[href=#{logout_path}")
   if @logged_in_user.is_a? Artist
      assert_select("a[href=#{artist_path(@logged_in_user)}")
    else
      assert_select("a[href=#{user_path(@logged_in_user)}")
    end
  end
end

shared_examples_for 'logged in artist' do
  describe "nav" do
    it 'has a nav bar with artist links' do
      assert_select('.sidebar-nav')
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

shared_examples_for "redirects to login" do
  it "redirects to login" do
    expect(response).to redirect_to(new_user_session_path)
  end
end

shared_examples_for "not logged in" do
  it { expect(controller.current_user).to eql nil }
end

# shared_examples_for 'standard sidebar layout' do
#   it_should_behave_like 'two column layout'
#   it 'has a new art sidebar element which is sorted' do
#     assert_select '.lcol .new_art'
#     new_art = assigns(:new_art)
#     new_art.should be_present
#     new_art.sort_by(&:created_at).reverse.map(&:id).should == new_art.map(&:id)
#   end
#   it 'has all the action buttons' do
#     ct = (Time.zone.now > Time.utc(2012,3,12)) ? 3 : 4
#     assert_select '.action_button', :count => ct
#   end
# end

# shared_examples_for 'two column layout' do
#   it 'has a two column body class' do
#     assert_select('body.two_column')
#   end
# end
# shared_examples_for 'one column layout' do
#   it 'has a one column body class' do
#     assert_select('.singlecolumn')
#   end
# end

shared_examples_for 'renders error page' do
  it "renders an error page with status 404" do
    expect(response).to render_template 'error/index'
    expect(response.code).to eql '404'
  end
end

shared_examples_for "not authorized" do
  it "redirects to error page" do
    expect(response).to redirect_to error_path
  end
end

shared_examples_for 'successful json' do
  it { 
    expect(response).to be_success 
    expect(response).to be_json
  }
end

