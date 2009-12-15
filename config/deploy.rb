set :application, "MAU"
set :repository,  "svn+ssh://n4.jimlloyd.com#2222/space/svnroot/projects/mau/mauweb"

set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/projects/mau/mauweb"

set :user, "jon"

role :app, "n4.jimlloyd.com:2222"
role :web, "n4.jimlloyd.com:2222"

role :db,  "n4.jimlloyd.com:2222", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start {}
#   task :stop {}
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
