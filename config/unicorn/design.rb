<<<<<<< HEAD
# frozen_string_literal: true

root = '/home/deploy/deployed/mau/current'
=======
root = "/home/deploy/deployed/mau/current"
>>>>>>> parent of 302f5f47... move config files to puma
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

# apache needs a port - not sockets
listen 5100
worker_processes 2
timeout 30

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
<<<<<<< HEAD
  ENV['BUNDLE_GEMFILE'] = File.join(root, 'Gemfile')
=======
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
>>>>>>> parent of 302f5f47... move config files to puma
end
