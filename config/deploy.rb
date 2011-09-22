require 'bundler/capistrano'
require 'rvm'
require 'rvm/capistrano'
set :rvm_ruby_string, '1.8.7-p302@mau'

####### VARIABLES #######
set :application, "MAU"
set :scm, :subversion
set :use_sudo, false
set :rake, 'bundle exec rake'

#########################
# Set repo based on incoming tag or branch variable
# inputs can be passed to capistrano via -S tag=<tag> 
# or -S branch=<branch>
#
if variables[:tag]
  deploy_version = "tags/%s" % variables[:tag]
elsif variables[:branch]
  deploy_version = "branches/%s" % variables[:branch]
else
  deploy_version = "trunk/"
end 

set :repository,  "svn+ssh://svn.bunnymatic.com/space/svnroot/mau/web/" + deploy_version

BUNNYMATIC = 'bunnymatic.com'
SLICE = '209.20.85.23'
# these roles represent the servers on which all these things run
# if db is run on different machine, you might change db
role :app, BUNNYMATIC
role :web, BUNNYMATIC
role :db,  BUNNYMATIC, :primary => true # This is where Rails migrations will run

####### Apache commands ####
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "sudo -u www /etc/init.d/httpd #{action.to_s}", :via => run_method
    end
  end
end

namespace :nginx do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Nginx"
    task action, :roles => :web do
      invoke_command "sudo -u www-data /etc/init.d/nginx #{action.to_s}", :via => run_method
    end
  end
end


####### CUSTOM TASKS #######
desc "Set up Test specific paramters."
task :jy do
  set :user, "jeremy"
  set :deploy_to, "/home/jeremy/deployed"
  set :svn_env, 'export SVN_SSH="ssh -p 2222"'
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
end

desc "Setup Staging on Slicehost params"
task :staging do
  set :user, "maudev"
  set :rails_env, 'development'
  set :deploy_to, "/home/maudev/deployed"
  set :ssh_port, '22022'
  set :svn_env, "export SVN_SSH=\"ssh -p #{ssh_port}\""
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
end

desc "Set up Dev on bunnymatic.com parameters."
task :dev do
  set :user, "maudev"
  set :rails_env, 'development'
  set :deploy_to, "/home/maudev/deployed"
  set :ssh_port, '2222'
  set :svn_env, "export SVN_SSH=\"ssh -p #{ssh_port}\""
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
end

desc "Set up Production bunnymatic.com parameters."
task :prod do
  set :user, "mauprod"
  set :deploy_to, "/home/mauprod/deployed"
  set :rails_env, 'production'
  set :ssh_port, '2222'
  set :svn_env, "export SVN_SSH=\"ssh -p #{ssh_port}\""
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
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
  run "mkdir -p #{sass_cache_dir} && chgrp web #{sass_cache_dir} && chmod g+ws #{sass_cache_dir}"
  run "cd #{current_path} && rvm use 1.8.7-p302@mau && #{rake} RAILS_ENV=#{rails_env} sass:build"
end

after 'bundle:install', 'deploy:migrate'
after "deploy:symlink", :symlink_data
after "deploy:symlink", :setup_backup_dir
after "deploy:symlink", "apache:reload"
before "apache:reload", :build_sass


desc "build db backup directory"
task :setup_backup_dir do
  run "rm -rf ~/deployed/current/backups"
  run "ln -s ~/deployed/shared/backups ~/deployed/current/backups"
end

desc "Connect artist and studio data to website"
task :symlink_data do
  run "rm -rf ~/deployed/current/public/artistdata"
  run "rm -rf ~/deployed/current/public/studiodata"
  run "ln -s ~/artistdata ~/deployed/current/public/artistdata"
  run "ln -s ~/studiodata ~/deployed/current/public/studiodata"
  run "test -e ~/deployed/current/public/REVISION || ln -s ~/deployed/current/REVISION ~/deployed/current/public/REVISION"
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
end

# namespace :deploy do
#   task :start {}
#   task :stop {}
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
