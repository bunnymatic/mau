namespace :db do
  desc 'Annotates model files'
  task :annotate => [:environment] do
    system("echo $PATH")
    system("bundle exec annotate -i -e tests,fixtures --force")
  end
end

Rake::Task['db:migrate'].enhance do
  Rake::Task['db:annotate'].invoke
end
