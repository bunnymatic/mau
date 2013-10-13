# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

#require 'thread'

require File.expand_path('../config/application', __FILE__)
require 'rake'

Mau::Application.load_tasks

#require(File.join(File.dirname(__FILE__), 'config', 'boot'))

# require 'rake'
# require 'rake/testtask'

# require 'tasks/rails'

# begin
#   require 'jslint/tasks'
#   JSLint.config_path = "config/jslint.yml"
# rescue Exception => ex
#   puts "Warning: unable to load jslint tasks. Shouldn't be required for production/staging environments"
# end

# require 'rosie'
# Dir["#{Gem.searcher.find('rosie').full_gem_path}/lib/tasks/**/*.rake"].each { |ext| load ext }

begin
  require 'rcov'
  require 'rcov/rcovtask'

  desc "Run RCov to get coverage of Specs"
  Rcov::RcovTask.new(:rcov_spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.verbose = true
    t.rcov_opts << "--html"
    t.rcov_opts << "--text-summary"
    t.rcov_opts << ['--exclude', 'spec']
    t.output_dir = "coverage/spec"
    t.libs << 'spec'
  end
rescue LoadError => ex
  puts "Failed to load RCov - rcov_spec task will not be available"
end
