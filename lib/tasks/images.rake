namespace :images do

  desc 'migrate images to s3'
  task migrate_to_s3: :environment do
    art_pieces = ArtPiece.joins(:artist).where(users: { state: 'active' }).readonly(false)
    files = art_pieces.map do |ap|
      image = File.join(Rails.root,ap.get_path(:original))
      if !File.exists?(image)
        image = File.join(Rails.root,'public', ap.get_path(:original))
      end
      [ap, image]
    end
    puts "Starting migration for #{files.count} files... "
    files.each_with_index do |(ap, image), idx|
      print "." if idx % 10 == 0
      next if ap.photo?
      fp = File.open(image)
      ap.photo = fp
      fp.close
      success = ap.save
      puts "Failed to migrate art piece #{ap.id}" unless success
    end
    puts "Done migrating #{files.count} files"
  end
end
