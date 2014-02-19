# adds db:create which seems to be missing from Cap3

namespace :db
  desc "Create Production Database"
    task :create do
      puts "\n\n=== Creating the Production Database! ===\n\n"
      run "cd #{current_path}; rake db:create RAILS_ENV=#{rails_env}"
      # system "cap deploy:set_permissions"
    end
  end
end
