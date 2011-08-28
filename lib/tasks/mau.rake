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

  namespace :images do
    desc 'build cropped thumbs - add force=true to force overwrites'
    task :build_cropped_thumbs => [:environment] do
      originals = []
      originals += ArtPiece.all.map{|ap| [ap.get_path('original'), ap.get_path('cropped_thumb')]}
      originals += Artist.all.map{|artist| [artist.get_profile_image('original'), artist.get_profile_image('cropped_thumb')]}
      originals += Studio.all.map{|studio| [studio.get_profile_image('original'), studio.get_profile_image('cropped_thumb')]}
      originals.each do |files|
        next if files.any?{|f| f.nil?}
        files = files.map{|f| File.join(Rails.root, 'public', f)}
        infile = files[0]
        outfile = files[1]
        if (ENV['force'] == 'true') || !File.exists?(outfile)
          MojoMagick::resize(infile, outfile, {:fill => true, :crop => true, :width => 127, :height => 127})
        end
      end
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
    
    desc "import database : specify database file with db=<databasefile.sql> on the command line"
    task :import => [:environment] do
      dbfile = ENV['db']
      unless dbfile.blank?
        env = ENV['RAILS_ENV']
        dbcnf = alldbconf[env]
        sh "mysql -u #{dbcnf['username']} -p#{dbcnf['password']} #{dbcnf['database']} < #{dbfile}"
        
        # reset all passwords to monkey
        #
        puts "updating artist passwords to monkey"
        Artist.all.each_with_index do |a, idx|
          if (0==(idx % 40))
            print '.'
          end
          a.update_attributes(:password => 'monkey', :password_confirmation => 'monkey')
        end
        puts "done"
      else
        puts "***"
        puts "*** import aborted"
        puts "*** You must specify a database file to import with db=<databasefilename.sql>"
        puts "***"
      end
    end
  end
  
  namespace :tags do
    desc "downcase existing tags"
    task :downcase => [:environment] do
      ArtPieceTag.all.select{|t| t.name != t.name.downcase }.each do |t|
        t.name = t.name.downcase
        t.save!
      end
    end
      
    desc "remove duplicate tags"
    task :cleanup => [:environment] do
      all_tags = ArtPieceTag.all
      tags_by_downcase = {}
      all_tags.each do |t|
        key = t.name.downcase
        if !tags_by_downcase.has_key?(key)
          tags_by_downcase[key] = {} 
          lowercase_tag = nil
          if key == t.name
            lowercase_tag = t
          else
            lowercase_tag = ArtPieceTag.create(:name => key)
          end
          tags_by_downcase[key][:id] = t.id
          tags_by_downcase[key][:tags] = [ t ]
        else
          tags_by_downcase[key][:tags] << t
        end
      end

      ct = nil;
      tags_by_downcase.each do |tagname, info|
        newtag = ArtPieceTag.find_by_name(tagname)
        ct = 0;
        info[:tags].each do |tag|
          to_update = ArtPiecesTag.find_all_by_art_piece_tag_id(tag.id)
          to_update.each do |apjoin|
            if apjoin.art_piece_tag_id != newtag.id
              sql = "update art_pieces_tags set art_piece_tag_id = #{newtag.id} where art_piece_id = #{apjoin.art_piece_id} and art_piece_tag_id = #{apjoin.art_piece_tag_id}"
              ActiveRecord::Base.connection.execute(sql)
              ct += 1
            end
          end
        end
      end
    end
  end
end
