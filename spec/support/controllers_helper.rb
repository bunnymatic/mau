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
    assert_select('.panel-group')
    assert_select('#info')
    assert_select('#profile_picture')
    assert_select('#password')
    assert_select('#links')
  end
end

# for all
shared_examples_for "logged in user" do
end

shared_examples_for 'logged in artist' do
end

shared_examples_for "logged in as editor" do
end

shared_examples_for "logged in as admin" do
end

shared_examples_for "redirects to login" do
  it "redirects to login" do
    expect(response).to redirect_to(new_user_session_path)
  end
end

shared_examples_for "not logged in" do
  it { expect(controller.current_user).to eql nil }
end


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

