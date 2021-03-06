begin
  namespace :spec do
    task enable_coverage: [:environment] do
      ENV['COVERAGE'] = '1'
    end

    # desc 'Executes specs with code coverage reports'
    # task :coverage => :enable_coverage do
    #   Rake::Task[:spec].invoke
    # end

    require 'rspec/core/rake_task'
    desc 'Runs all rspec specs'
    RSpec::Core::RakeTask.new(:all, [:environment])
  end
rescue LoadError
  task spec: [:environment] do
    puts 'Failed to load rspec'
  end
end
