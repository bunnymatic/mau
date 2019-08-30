# frozen_string_literal: true

# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/rails'
<<<<<<< HEAD
require 'capistrano/scm/git'
require 'capistrano3/unicorn'

install_plugin Capistrano::SCM::Git
=======
require 'capistrano3/unicorn'
>>>>>>> parent of 302f5f47... move config files to puma

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('./config/capistrano/tasks/*.cap').each { |r| import r }
