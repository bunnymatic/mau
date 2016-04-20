begin
  namespace :spec do
    desc "Run all javascript specs"
    task javascripts: [:teaspoon]
  end
end

Rake::Task['spec'].clear_actions

desc 'Runs all specs'
task spec: ['spec:enable_coverage', 'spec:all', 'spec:javascripts',  'cucumber:ok']
