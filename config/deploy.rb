####### VARIABLES #######
set :ssh_options,         {:port => 2222}
set :application, "MAU"
set :scm, :subversion
set :use_sudo, false

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

# these roles represent the servers on which all these things run
# if db is run on different machine, you might change db
role :app, "bunnymatic.com"
role :web, "bunnymatic.com"
role :db,  "bunnymatic.com", :primary => true # This is where Rails migrations will run

####### Apache commands ####
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "sudo -u www /etc/init.d/httpd #{action.to_s}", :via => run_method
    end
  end
end

####### CUSTOM TASKS #######
desc "Set up Staging specific paramters."
task :jy do
  set :user, "jeremy"
  set :deploy_to, "/home/jeremy/deployed"
  set :svn_env, 'export SVN_SSH="ssh -p 2222"'
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
end

desc "Set up Staging specific paramters."
task :dev do
  set :user, "maudev"
  set :rails_env, 'development'
  set :deploy_to, "/home/maudev/deployed"
  set :svn_env, 'export SVN_SSH="ssh -p 2222"'
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
end

desc "Set up Production specific paramters."
task :prod do
  set :user, "mauprod"
  set :deploy_to, "/home/mauprod/deployed"
  set :rails_env, 'production'
  set :svn_env, 'export SVN_SSH="ssh -p 2222"'
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
end

desc "Sanity Check"
task :checkit do
  puts("User: %s" % user)
  puts("Env: %s" % rails_env)
  puts("Repo: %s" % repository)
  puts("DeployDir: %s" % deploy_to)
end

before "apache:reload" do
  run "cd #{current_path} && rake RAILS_ENV=#{rails_env} sass:build"
end

after "deploy:symlink", :symlink_data
after "deploy:symlink", "apache:reload"


desc "Connect artist and studio data to website"
task :symlink_data do
  run "rm -rf ~/deployed/current/public/artistdata"
  run "rm -rf ~/deployed/current/public/studiodata"
  run "ln -s ~/artistdata ~/deployed/current/public/artistdata"
  run "ln -s ~/studiodata ~/deployed/current/public/studiodata"
  run "test -e ~/deployed/current/public/REVISION || ln -s ~/deployed/current/REVISION ~/deployed/current/public/REVISION"
end




# namespace :deploy do
#   task :start {}
#   task :stop {}
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
