####### VARIABLES #######
set :ssh_options,         {:port => 2222}
set :application, "MAU"
set :repository,  "svn+ssh://bunnymatic.com/space/svnroot/mau/web/trunk"
set :scm, :subversion
set :use_sudo, false

role :app, "bunnymatic.com"
role :web, "bunnymatic.com"
role :db,  "bunnymatic.com", :primary => true # This is where Rails migrations will run

####### CUSTOM TASKS #######
desc "Set up Staging specific paramters."
task :jy do
  set :user, "jeremy"
  set :deploy_to, "/home/jeremy/deployed"
  set :svn_env, 'export SVN_SSH="ssh -p 2222"'
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
  # set :db_pass, "9XfqzzL9"
  # set :db_env, "staging"
end

desc "Set up Staging specific paramters."
task :dev do
  set :user, "maudev"
  set :deploy_to, "/home/maudev/deployed"
  set :svn_env, 'export SVN_SSH="ssh -p 2222"'
  puts("executing locally \'" + svn_env + "\'")
  system(svn_env)
  # set :db_pass, "9XfqzzL9"
  # set :db_env, "staging"
end

desc "Set up Production specific paramters."
task :prod do
  set :user, "mauprod"
  set :deploy_to, "/home/mauprod/deployed"
end

after "deploy:symlink", :symlink_data

desc "Connect artist and studio data to website"
task :symlink_data do
  run "rm -rf ~/deployed/current/public/artistdata"
  run "rm -rf ~/deployed/current/public/studiodata"
  run "ln -s ~/artistdata ~/deployed/current/public/artistdata"
  run "ln -s ~/studiodata ~/deployed/current/public/studiodata"
end


# namespace :deploy do
#   task :start {}
#   task :stop {}
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
