begin
  require 'rcov'
  require 'rcov/rcovtask'

  desc "Run RCov to get coverage of Specs"
  Rcov::RcovTask.new do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.verbose = true
    t.rcov_opts << "--html"
    t.rcov_opts << "--text-summary"
    t.rcov_opts << ['--exclude', 'spec,/gems,/Library,/usr,lib/tasks']
    t.output_dir = "coverage/spec"
    t.libs << 'spec'
  end

  task :default => [:rcov]

rescue LoadError => ex
  puts "Failed to load RCov - rcov_spec task will not be available"
end
