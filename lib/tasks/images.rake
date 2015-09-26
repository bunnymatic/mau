namespace :images do

  desc 'migrate images to s3'
  task migrate_to_s3: :environment do
    files = []

    def get_image_filename(obj)
      image = File.join(Rails.root,obj.get_path(:original))
      if !File.exists?(image)
        image = File.join(Rails.root,'public', obj.get_path(:original))
      end
    end

    art_pieces = ArtPiece.joins(:artist).where(users: { state: 'active' }).readonly(false)
    files = art_pieces.map {|ap| [ap, get_image_filename(ap)]}

    studios = Studio.all
    files += studios.map {|ap| [ap, get_image_filename(ap)]}

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
