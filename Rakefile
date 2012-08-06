# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'thread'

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'jslint/tasks'
  JSLint.config_path = "config/jslint.yml"
rescue Exception => ex
  puts "Warning: unable to load jslint tasks. Shouldn't be required for production/staging environments"
end

begin
  load "barista/tasks/barista.rake"
rescue Exception => ex
  puts "Warning: unable to load barista tasks. Shouldn't be required for production/staging environments"
end

require 'rosie'
Dir["#{Gem.searcher.find('rosie').full_gem_path}/lib/tasks/**/*.rake"].each { |ext| load ext }
