require 'rvm/capistrano'
require 'bundler/capistrano'
set :rvm_ruby_string, '1.8.7-p334@mau'
set :rvm_type, :user

# capistrano task order of operations as of 4/22/2012
#    deploy
#    deploy:update
#    deploy:update_code
#    deploy:finalize_update
#    bundle:install
#    deploy:migrate
#    deploy:create_symlink
#    deploy:restart
#    apache:reload
#    build_sass
#    deploy:cleanup
#    ping


####### VARIABLES #######
set :application, "MAU"
set :scm, :git
set :use_sudo, false
set :rake, 'bundle exec rake'
set :repository,  "git@git.rcode5.com:/space/git/mau.git"
set :branch, "master"
set :scm_verbose, true

####### Apache commands ####
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "sudo /etc/init.d/apache2 #{action.to_s}", :via => run_method unless rails_env != 'production'
    end
  end
end

namespace :nginx do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Nginx"
    task action, :roles => :web do
      invoke_command "sudo /etc/init.d/nginx #{action.to_s}", :via => run_method
    end
  end
end


####### CUSTOM TASKS #######
desc "Set up Dev on bunnymatic.com parameters."
task :dev do
  # these roles represent the servers on which all these things run
  # if db is run on different machine, you might change db
  set :app_host, 'mau.rcode5.com'
  role :app, app_host
  role :web, app_host
  role :db, app_host, :primary => true # This is where Rails migrations will run

  set :user, "deploy"
  set :rails_env, 'development'
  set :deploy_to, "/home/deploy/mau"
  set :ssh_port, '22022'
  set :server_name, 'mau.rcode5.com'
end

desc "Set up Production bunnymatic.com parameters."
task :prod do
  set :app_host, '50.97.213.210' #site5 host
  role :app, app_host
  role :web, app_host
  role :db, app_host, :primary => true # This is where Rails migrations will run
  set :user, "missiona"
  set :deploy_to, "/home/missiona/deployed/mau"
  set :rails_env, 'production'
  set :server_name, 'missionartistsunited.org'
end

desc "Sanity Check"
task :checkit do
  puts("User: %s" % user)
  puts("Env: %s" % rails_env)
  puts("Repo: %s" % repository)
  puts("DeployDir: %s" % deploy_to)
  puts("SSH Port: %s" % ssh_port)
end

task :build_sass do
  sass_cache_dir = "#{current_path}/tmp/sass-cache"
  run "mkdir -p #{sass_cache_dir} && chmod g+ws #{sass_cache_dir}"
  run "cd #{current_path} && rvm use #{rvm_ruby_string} && RAILS_ENV=#{rails_env} #{rake} sass:build"
end

after 'bundle:install', 'deploy:migrate'
before "deploy:restart", :symlink_data
before "apache:reload", :build_sass
after "deploy", "apache:reload"
after "deploy", 'deploy:cleanup'
after "deploy", :ping

desc "build db backup directory"
task :setup_backup_dir do
  run "rm -rf #{current_path}/backups"
  run "ln -s #{shared_path}/backups #{current_path}/backups"
end

desc "Connect artist and studio data to website"
task :symlink_data do
  run "rm -rf #{current_path}/public/artistdata"
  run "rm -rf #{current_path}/public/studiodata"
  run "ln -s #{shared_path}/system/artistdata #{current_path}/public/artistdata"
  run "ln -s #{shared_path}/system/studiodata #{current_path}/public/studiodata"
  run "test -e #{current_path}/public/REVISION || ln -s #{current_path}/REVISION #{current_path}/public/REVISION"
end

desc "put htaccess in place (if available)" 
task :copy_htaccess do
  run "[[ -f #{shared_path}/_htacess ]] && cp #{shared_path}/_htaccess #{current_path}/public/.htaccess"
end

# for passenger
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  namespace :web do
    desc "turn on maintenance mode"
    task :disable do
      run "touch #{current_path}/public/maintenance_mode.txt"
    end

    desc "turn off maintenance mode"
    task :enable do
      run "rm -rf #{current_path}/public/maintenance_mode.txt"
    end
  end
end

desc "ping the server"
task :ping do
  run "curl -s http://#{server_name}/feeds/feed"
  run "curl -s http://#{server_name}"
end

# namespace :deploy do
#   task :start {}
#   task :stop {}
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
