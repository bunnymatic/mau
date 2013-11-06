begin
  namespace :spec do
    task :enable_coverage do
      ENV['COVERAGE'] = '1'
    end

    desc 'Executes specs with code coverage reports'
    task :coverage => :enable_coverage do
      Rake::Task[:spec].invoke
    end

    require 'rspec/core/rake_task'
    desc 'Runs all rspec specs'
    RSpec::Core::RakeTask.new(:all)
  end

  task(:spec).clear.enhance(['db:test:prepare', 'spec:enable_coverage', 'spec:all', 'cucumber:ok'])
rescue LoadError
  task :spec do
    puts "Failed to load rspec"
  end
end
