begin
  require 'rspec/core'
  require 'rspec/core/rake_task'

  namespace :spec do
    desc 'Run all javascript specs'
    task javascripts: ['jest:test']

    desc 'Run the code examples in spec/ except those in spec/system'
    RSpec::Core::RakeTask.new(:without_features) do |t|
      t.exclude_pattern = 'spec/features/**/*_spec.rb'
    end
  end
rescue LoadError
  print 'RSpec not included.  Nothing to do here'
end

Rake::Task['spec'].clear_actions

desc 'Runs all specs'
task spec: [
  'rubocop',
  'js:lint',
  'spec:enable_coverage',
  'spec:all',
  'spec:javascripts',
  'cucumber:ok',
]

# task default: [:spec]
