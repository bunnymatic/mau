require_relative '../../lib/mau_image/paperclip'

module HasAttachedImage
  extend ActiveSupport::Concern

  included do
    class_attribute :_image_attachments, instance_accessor: false
    self._image_attachments = Set.new
  end

  private

  def attachments_by_name(name)
    clz = self.class.name
    ActiveStorage::Attachment.where(record_id: id, record_type: clz, name: name).order(:id)
  end

  class_methods do
    # rubocop:disable Style/DocumentDynamicEvalDefinition
    #
    # I followed rubocop rules and added comments documenting the methods but
    # it's still not passing for some reason.  Something to figure out later.
    def image_attachments(*attachment_names)
      self._image_attachments = Set.new(attachment_names.map(&:to_s))
      attachment_names.each do |name|
        # def attached_photo?
        #   self.public_send('photo').nil?
        # end
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def attached_#{name}?
            self.public_send('#{name}').present?
          end
        RUBY

        # def attached_photo(size = :medium)
        #   begin
        #     att = attachments_by_name('photo').last
        #     if att
        #       att.variant(MauImage::Paperclip::VARIANT_RESIZE_ARGUMENTS[size.to_sym]).processed.url
        #     end
        #   rescue ActiveStorage::FileNotFoundError => e
        #     return nil
        #   rescue Aws::S3::Errors::BadRequest => e
        #     Rails.logger.error(e.backtrace.join("\\n"))
        #   end
        # end
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def attached_#{name}(size = :medium)
            begin
              variant = self.public_send('#{name}').variant(MauImage::Paperclip::VARIANT_RESIZE_ARGUMENTS[size.to_sym])&.processed
              Rails.application.routes.url_helpers.rails_representation_url(variant) if variant
            rescue ActiveStorage::FileNotFoundError => e
              return nil
            rescue Aws::S3::Errors::BadRequest => e
              Rails.logger.error(e.backtrace.join("\\n"))
            end
          end
        RUBY
      end
    end
    # rubocop:enable Style/DocumentDynamicEvalDefinition
  end
end
