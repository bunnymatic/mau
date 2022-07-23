module DuplicateActiveStorage
  extend ActiveSupport::Concern

  included do
    after_commit do
      duplicate_active_storage unless @is_migration
    end
    after_destroy :duplicate_active_storage
  end

  def duplicate_active_storage(*_args)
    return if skip_transfer

    if try(:deleted?) || destroyed?
      remove_active_storage
      return
    end

    ActiveRecord::Base.transaction do
      create_active_storage_entry
    rescue StandardError => e
      Rails.logger.error(e)
      raise
    end
    clear_attribute_changes(["#{self.class.paperclip_attachment_name}_updated_at"])
  end

  private

  def skip_transfer
    return true unless !saved_change_to_attribute("#{self.class.paperclip_attachment_name}_updated_at").nil? ^ @is_migration

    if instance_of?(ArtPiece)
      # art piece photo is required
      # this will force the migration to run *even* if the
      # file path is bogus which will them properly mark the
      # picture as failed and we'll have to deal with it later
      false
    else
      photo_exists_method = "#{self.class.paperclip_attachment_name}?"
      !public_send(photo_exists_method)
    end
  end

  def create_active_storage_entry
    blob = create_blob
    blob&.attachments&.create(
      name: self.class.paperclip_attachment_name,
      record_type: self.class.name,
      record_id: id,
    )
  end

  def create_blob
    # rubocop:disable Security/Open
    if using_s3?
      s3_url = "https://#{Rails.application.config.s3_info[:bucket]}.s3.amazonaws.com/#{key(self.class.paperclip_attachment_name)}"
      ActiveStorage::Blob.create_after_upload!(
        io: URI.open(Addressable::URI.parse(s3_url).display_uri.to_s),
        filename: send("#{self.class.paperclip_attachment_name}_file_name"),
        content_type: send("#{self.class.paperclip_attachment_name}_content_type"),
        service_name: :amazon,
      )
    else
      begin
        file = Rails.root.join(send(paperclip_attachment_name).path)
        ActiveStorage::Blob.create_after_upload!(
          io: open(file),
          filename: send("#{paperclip_attachment_name}_file_name"),
          content_type: send("#{paperclip_attachment_name}_content_type"),
          service_name: :test,
        )
      rescue StandardError
        logger.error("Failed to create blob from file - hopefully this is in tests and you don't really care")
        nil
      end
    end
    # rubocop:enable Security/Open
  end

  def using_s3?
    # We are assuming that active storage and paperclip are the same config
    # that is, both amazon or both filesystem
    # Filesystem is really only used in test right now but... you could imagine it in development
    Paperclip::Attachment.default_options[:storage].to_sym == :s3
  end

  def key(attachment)
    filename = send("#{attachment}_file_name")
    klass = self.class.table_name
    klass = 'artists' if klass == 'users'
    id = self.id
    id_partition = ('%09d'.freeze % id).scan(/\d{3}/).join('/'.freeze)

    "#{klass}/#{attachment.to_s.pluralize}/#{id_partition}/original/#{filename}"
  end

  def remove_active_storage
    ActiveStorage::Attachment.find_by(record_type: self.class.name, record_id: id)&.purge
  end
end
