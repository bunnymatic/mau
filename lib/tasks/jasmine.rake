begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
  
  namespace :jasmine do
    desc 'run jasmine-headless-webkit'
    task :headless do
      system "jasmine-headless-webkit"
    end
  end
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end
