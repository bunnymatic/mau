# frozen_string_literal: true
root = "/home/deploy/deployed/mau/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.mau.sock"
worker_processes 5
timeout 30

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end

# config/unicorn.rb
before_fork do |_server, _worker|
  # other settings
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |_server, _worker|
  # other settings
  if defined?(ActiveRecord::Base)
    config = ActiveRecord::Base.configurations[Rails.env] ||
             Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['DB_POOL'] || 5
    ActiveRecord::Base.establish_connection(config)
  end
end
