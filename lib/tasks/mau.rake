require 'find'
require 'ftools'
require 'yaml'

alldbconf = YAML.load_file( File.join( [Rails.root, 'config','database.yml' ] ))

namespace :mau do
  desc "Send twitter updates about artists who've updated their art today"
  task :tweetart => [:environment] do
    aps = ArtPiece.get_todays_art
    if aps.length 
      artists = Artist.active.find_all_by_id( aps.map{ |ap| ap.artist_id })
      names = artists.map{|a| a.get_name}
    end
  end

  namespace :db do
    desc "backup the database"
    task :backup => [:environment] do
      env = ENV['RAILS_ENV']
      dbcnf = alldbconf[env]
      ts = Time.now.strftime('%Y%m%d%H%m%S')
      db_backup_dir = File.join( [Rails.root, 'backups','db', ts]);
      db_file = "#{dbcnf['database']}-#{ts}.backup.sql"
      path = File.join([db_backup_dir, db_file])
      sh "mkdir -p #{db_backup_dir} && mysqldump -u #{dbcnf['username']} -p#{dbcnf['password']} --single-transaction #{dbcnf['database']} > #{path}"
      # tar up artists data dir
    end
  end
end
