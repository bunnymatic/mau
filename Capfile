# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/rails'
require 'capistrano/puma'
require 'capistrano/puma/workers'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('./config/capistrano/tasks/*.cap').each { |r| import r }
