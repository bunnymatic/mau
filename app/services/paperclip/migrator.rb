module Paperclip
  class Migrator
    attr_reader :model

    def initialize(model)
      @model = model
    end

    def run
      return unless attachments?

      instance = next_record
      if instance
        backfill(instance)
      else
        Rails.logger.warn("No more records of #{model} to migrate")
      end
    rescue OpenURI::HTTPError, ActiveRecord::StatementInvalid => e
      mark_instance_failed(instance)
      Rails.logger.error("Error during ActiveStorage migration: #{e} #{model} #{instance&.id}")
      Rails.logger.warn('Skipping to the next one')
    rescue StandardError => e
      Rails.logger.error("Error during ActiveStorage migration: #{e} #{model} #{instance&.id}")
      Rails.logger.warn("Not marking failed because we don't understand why")
    end

    def attachments
      @attachments ||= model.column_names.filter_map do |column|
        column[/(?<name>\w*)_file_name/, :name] if column.match?(/(.+)_file_name$/)
      end
    end

    def attachments?
      attachments.present?
    end

    def record_types
      if model == Artist
        %w[Artist User]
      else
        [model.name]
      end
    end

    def next_record
      records = model.where.not(attachment_file_name_field => nil)
                     .where.not(
                       id: ActiveStorage::Attachment.where(record_type: record_types).distinct(:record_id).pluck(:record_id),
                     )
                     .where(failed_migration_field => nil)
      records.first
    end

    def backfill(instance)
      Rails.logger.info("Backfilling #{instance.class.name}##{instance.id}")
      instance.instance_variable_set(:@is_migration, true)
      instance.duplicate_active_storage if instance.respond_to?(:duplicate_active_storage)
    end

    def mark_instance_failed(instance)
      return unless instance

      instance.update_column(failed_migration_field, Time.current) # rubocop:disable Rails/SkipsModelValidations
    end

    def attachment_file_name_field
      "#{model.paperclip_attachment_name}_file_name".freeze
    end

    def failed_migration_field
      "#{model.paperclip_attachment_name}_migrate_to_active_storage_failed_at".freeze
    end
  end
end
