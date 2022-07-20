module HasAttachedImage
  extend ActiveSupport::Concern

  included do
    class_attribute :_image_attachments, instance_accessor: false
    self._image_attachments = Set.new
  end

  private

  def attachments_by_name(name)
    ActiveStorage::Attachment.where(record_id: id, record_type: self.class.name, name: name).order(:id)
  end

  def paperclip_attachment_exists?(name)
    method = "#{name}?"
    respond_to?(method) && public_send(method)
  end

  class_methods do
    # rubocop:disable Style/DocumentDynamicEvalDefinition
    #
    # I followed rubocop rules and added comments documenting the methods but
    # it's still not passing for some reason.  Something to figure out later.
    def image_attachments(*attachment_names)
      self._image_attachments = Set.new(attachment_names.map(&:to_s))
      attachment_names.each do |name|
        # def photo_attachment?
        #   attachments_by_name('photo').exists? || paperclip_attachment_exists?('photo')
        # end
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{name}_attachment?
             attachments_by_name('#{name}').exists? || paperclip_attachment_exists?('#{name}')
          end
        RUBY

        # def photo_attachment(size = :medium)
        #   begin
        #     att = attachments_by_name('photo').last
        #     return att.variant(MauImage::Paperclip::VARIANT_RESIZE_ARGUMENTS[size.to_sym]).processed.url if att
        #   rescue Aws::S3::Errors::BadRequest => e
        #     Rails.logger.error(e.backtrace.join("\\n"))
        #   end
        #
        #   photo(size) if photo?
        # end
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{name}_attachment(size = :medium)
            begin
              att = attachments_by_name('#{name}').last
              return att.variant(MauImage::Paperclip::VARIANT_RESIZE_ARGUMENTS[size.to_sym]).processed.url if att
            rescue Aws::S3::Errors::BadRequest => e
              Rails.logger.error(e.backtrace.join("\\n"))
            end

            #{name}(size) if #{name}?
          end
        RUBY
      end
    end
    # rubocop:enable Style/DocumentDynamicEvalDefinition
  end
end
