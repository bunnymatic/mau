#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# Load RVM's capistrano plugin.

case Rails.env
  when 'production'
  require "bundler/capistrano"
  
  load 'deploy' if respond_to?(:namespace) # cap2 differentiator
  Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
  
  load 'config/deploy_site5' # remove this line to skip loading any of the default tasks
  else
  require "rvm/capistrano"
  set :rvm_ruby_string, '1.8.7-p302@mau'
  
  load 'deploy' if respond_to?(:namespace) # cap2 differentiator
  Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
  
  load 'config/deploy' # remove this line to skip loading any of the default tasks
end
