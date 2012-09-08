require 'find'
require 'fileutils'
require 'yaml'

alldbconf = YAML.load_file( File.join( [Rails.root, 'config','database.yml' ] ))

namespace :mau do

  desc 'import scammer emails from FASO'
  task :import_scammer_list => [:environment] do
    Scammer.importFromFASO
  end

  desc 'reset all passwords to "bmatic"'
  task :reset_passwords => [:environment] do
    User.all.each do |u|
      u.password = 'bmatic'
      u.password_confirmation = 'bmatic'
      u.save
    end
  end

  desc 'normalize emails - convert everyone to "@example.com"'
  task :normalize_emails => [:environment] do
    User.all.each do |u|
      u.update_attribute(:email, u.email.gsub(/^(.*)\@(.*)/,'\1@example.com'))
    end
  end

  desc "Send twitter updates about artists who've updated their art today"
  task :tweetart => [:environment] do
    aps = ArtPiece.get_todays_art
    if aps.length 
      artists = Artist.active.find_all_by_id( aps.map{ |ap| ap.artist_id })
      names = artists.map{|a| a.get_name}
    end
  end

  namespace :images do
    desc 'build large images'
    task :build_large_image => [:environment] do
      originals = []
      originals += ArtPiece.all.map{|ap| [ap.get_path('original'), ap.get_path('large')]}
      originals += Artist.all.map{|artist| [artist.get_profile_image('original'), artist.get_profile_image('large')]}
      originals += Studio.all.map{|studio| [studio.get_profile_image('original'), studio.get_profile_image('large')]}

      originals.select{|f| f.all?{|ff| !ff.nil?}}.each do |files|
        infile, outfile = files.map{|f| File.join(Rails.root, 'public', f)}
        if File.exists?(infile) && ((ENV['force'] == 'true') || !File.exists?(outfile))
          MojoMagick::shrink infile, outfile, {:width => 800, :height => 800}
        end
      end
    end

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
    
    desc 'repair image filenames (make ..jpg into .jpg)'
    task :repair_filenames => [:environment] do
      ArtPiece.all.select{|a| /\.{2,}/.match(a.filename)}.each do |ap|
        ArtPiece.transaction do
          old_filename = ap.filename
          new_filename = ap.filename.gsub(/\.{2,}/, '.')
          ap.update_attribute(:filename, new_filename)
          puts "Trying to update artist #{ap.artist.id} and art_piece #{ap.id}"
          begin
            
            full_old = File.join(Rails.root, old_filename)
            full_new = File.join(Rails.root, new_filename)
            full_old = File.join(Rails.root, 'public', old_filename) if !File.exists?(full_old)
            full_new = File.join(Rails.root, 'public', new_filename) if !File.exists?(full_new)

            if File.exists?(full_old)
              FileUtils.mv full_old, full_new
              [:m, :t, :l, :s].each do |pfx|
                oldf = File.split(full_old)
                newf = File.split(full_new)
                newf.push(newf.pop.gsub(/\.{2,}/, '.').insert(0,pfx.to_s + "_"))
                oldf.push(oldf.pop.insert(0,pfx.to_s + "_"))
                o = File.join(oldf)
                n = File.join(newf)
                FileUtils.mv o, n if File.exists?(o)
              end
            else
              puts "Unable to find file #{full_old}"
            end
          rescue Exception => ex
            puts "Failed to update filename for #{ap.inspect}"
            puts "Failure: ", ex
            raise
          end
        end
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
