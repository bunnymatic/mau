namespace :paperclip do
  # desc 'Migrate paperclip attachments to active storage'
  # task migrate: :environment do
  #   # this list is manually managed and should include any class
  #   # that has an attachment
  #   # models = [User, ArtPiece, Studio]
  #   models = [Studio, ArtPiece, Artist]
  #   models.map do |model|
  #     puts("Working on #{model.name}")
  #     begin
  #       attachments = model.column_names.filter_map do |column|
  #         column[/(?<name>\w*)_file_name/, :name] if column.match?(/(.+)_file_name$/)
  #       end
  #       next if attachments.blank?

  #       attachments.each do |attachment|
  #         query = <<~SQL.squish
  #           NOT EXISTS(
  #              SELECT * FROM active_storage_blobs AS blobs
  #              INNER JOIN active_storage_attachments AS attachments ON attachments.blob_id = blobs.id
  #              WHERE record_type = ? AND record_id = #{model.table_name}.id
  #           )
  #         SQL
  #         model.where.not("#{attachment}_file_name" => nil).where(query, model.name).find_each do |instance|
  #           instance.instance_variable_set(:@is_migration, true)
  #           instance.duplicate_active_storage if instance.respond_to?(:duplicate_active_storage)
  #         end
  #       end
  #     rescue OpenURI::HTTPError, ActiveRecord::StatementInvalid => e
  #       Rails.logger.error("Error during ActiveStorage migration: #{e} \n for #{model}")
  #       Raven.capture_exception("Error during ActiveStorage migration: #{e} \n for #{model}")
  #       next
  #     end
  #   end
  # end

  # desc "Migrate next unmigrated artist to paperclip"
  # task migrate_artist: :environment do
  #   begin
  #     model = Artist
  #     record_types = ['Artist', 'User']

  #     attachments = model.column_names.filter_map do |column|
  #       column[/(?<name>\w*)_file_name/, :name] if column.match?(/(.+)_file_name$/)
  #     end
  #     next if attachments.blank?

  #     attachments.each do |attachment|
  #       query = <<~SQL.squish
  #           NOT EXISTS(
  #              SELECT * FROM active_storage_blobs AS blobs
  #              INNER JOIN active_storage_attachments AS attachments ON attachments.blob_id = blobs.id
  #              WHERE record_type in (?) AND record_id = #{model.table_name}.id
  #           )
  #         SQL
  #       model.where.not("#{attachment}_file_name" => nil).where(query, record_types, model.name).first
  #         instance.instance_variable_set(:@is_migration, true)
  #         instance.duplicate_active_storage if instance.respond_to?(:duplicate_active_storage)
  #       end
  #     end
  #   rescue OpenURI::HTTPError, ActiveRecord::StatementInvalid => e
  #     Rails.logger.error("Error during ActiveStorage migration: #{e} \n for #{model}")
  #     Raven.capture_exception("Error during ActiveStorage migration: #{e} \n for #{model}")
  #     next
  #   end
  # end
end
