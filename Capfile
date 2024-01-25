# frozen_string_literal: true

# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'capistrano/scm/git'
require 'capistrano/puma'
require 'capistrano/local_precompile'

install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('./config/capistrano/tasks/*.cap').each { |r| import r }
