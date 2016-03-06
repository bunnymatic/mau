#workers Integer(ENV['PUMA_WORKERS'] || 2)
threads Integer(ENV['MIN_THREADS']  || 3), Integer(ENV['MAX_THREADS'] || 20)

#preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

cwd = File.dirname(__FILE__) + "/.."

directory cwd

pidfile "#{cwd}/tmp/pids/puma.pid"
state_path "#{cwd}/tmp/pids/puma.state"

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
