#require File.join(File.dirname(__FILE__), "rails", "init")

require File.join(File.dirname(__FILE__), "lib", "authentication")
require File.join(File.dirname(__FILE__), "lib", "authentication", "by_password")
require File.join(File.dirname(__FILE__), "lib", "authentication", "by_cookie_token")

require File.join(File.dirname(__FILE__), "lib", "authorization")
require File.join(File.dirname(__FILE__), "lib", "authorization", "stateful_roles")
require File.join(File.dirname(__FILE__), "lib", "authorization", "aasm_roles")

