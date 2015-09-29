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
        if path && !path.to_s.start_with?(Rails.root.to_s)
          File.join(Rails.root, path)
        elsif path
          path
        end
      end
    end

    def get_image_filename(obj)
      f = PathFinder.new(obj).image_path
      f if f && File.exists?(f)
    end

    art_pieces = ArtPiece.joins(:artist).where(users: { state: 'active' }).readonly(false)
    files = art_pieces.map {|ap| [ap, get_image_filename(ap)]}

    studios = Studio.all
    files += studios.map {|ap| [ap, get_image_filename(ap)]}

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
    puts "Done migrating #{files.count} files"
  end
end
