namespace :images do

  desc 'migrate images to s3'
  task migrate_to_s3: :environment do
    files = []

    class PathFinder
      def initialize(obj)
        @model = obj
      end

      def image_path
        path = case @model.class.name
               when 'Artist'
                 @model.profile_image
               when 'ArtPiece'
                 @model.filename
               when 'Studio'
                 @model.profile_image
               else
                 nil
               end
        File.expand_path(path) if path
      end
    end

    def get_image_filename(obj)
      f = PathFinder.new(obj).image_path
      if f && !File.exists?(f)
        f = begin
              if /artistdata/ =~ f && /public/ !~ f
                f.gsub /artistdata\//, "public/artistdata/"
              elsif /studiodata/ =~ f && /public/ !~ f
                f.gsub /studiodata\//, "public/studiodata/"
              end
            end
        if !File.exists?(f)
          return nil
        end
      end
      f
    end

    art_pieces = ArtPiece.joins(:artist).where(users: { state: 'active' }).readonly(false)
    files = art_pieces.map {|ap| [ap, get_image_filename(ap)]}

    studios = Studio.all
    files += studios.map {|s| [s, get_image_filename(s)]}

    artists = Artist.active.all
    files += artists.map {|a| [a, get_image_filename(a)]}
    files.reject!{|f| f[1].nil?}
    puts "Starting migration for #{files.count} files... "
    files.each_with_index do |(obj, image), idx|
      print "." if idx % 10 == 0
      next if obj.photo?
      fp = File.open(image)
      obj.photo = fp
      fp.close
      success = obj.save
      puts "Failed to migrate art piece #{obj.id}" unless success
    end
    puts "\nDone migrating #{files.count} files"
  end
end
