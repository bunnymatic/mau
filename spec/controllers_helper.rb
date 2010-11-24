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
    response.should_not be_success
    response.should redirect_to( new_session_path )
  end
end


def response_should_be_json
  Mime::Type.lookup(response.content_type).to_sym.should eql :json
end
