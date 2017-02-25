# frozen_string_literal: true
lock '3.7.1'

set :stages, %w(production acceptance)

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.3.3'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

set :application, 'MAU'
set :repo_url, 'git@github.com:bunnymatic/mau.git'

# set :rails_env, 'production'                  # If the environment differs from the stage name
# set :migration_role, 'migrator'            # Defaults to 'db'
set :assets_roles, [:web, :app] # Defaults to [:web]
# set :assets_prefix, 'prepackaged-assets'   # Defaults to 'assets' this should match config.assets.prefix in your rails config/application.rb

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/config.keys.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :rails_env, (fetch(:rails_env) || fetch(:stage))

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:reload'
  end

  desc "Reindex Elasticsearch indeces"
  task :es_reindex do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: fetch(:rails_env) do
          # execute :rake, "es:reindex"
        end
      end
    end
  end

  after :publishing, :es_reindex
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
