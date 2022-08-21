require_relative '../../lib/mau_image/paperclip'

module HasAttachedImage
  extend ActiveSupport::Concern

  included do
    class_attribute :_sti_class_names, instance_accessor: false
    self._sti_class_names = Set.new
  end

  private

  class_methods do
    attr_accessor :_sti_class_names

    # rubocop:disable Style/DocumentDynamicEvalDefinition
    #
    # I followed rubocop rules and added comments documenting the methods but
    # it's still not passing for some reason.  Something to figure out later.
    def image_attachments(*attachment_names, sti_class_names: nil)
      image_attachments = Set.new(attachment_names.map(&:to_s))
      self._sti_class_names = Set.new([name, sti_class_names].flatten.compact)

      image_attachments.each do |name|
        # has_one_attached :photo
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          has_one_attached :#{name}
        RUBY

        # def attached_photo_collection
        #   # STI needs to query parent classes
        #   clz = self.class._sti_class_names
        #   att = ActiveStorage::Attachment.where(record_id: id, record_type: clz, name: 'photo').order(:id)
        # end
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def attached_#{name}_collection
            # STI needs to query parent classes
            clz = self.class._sti_class_names
            att = ActiveStorage::Attachment.where(record_id: id, record_type: clz, name: '#{name}').order(:id)
          end
        RUBY

        # def attached_photo?
        #   attached_photo_collection.exists?
        # end
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def attached_#{name}?
            attached_#{name}_collection.exists?
          end
        RUBY

        # def attached_photo(size = :medium)
        #   begin
        #     # STI needs to query parent classes
        #     att = attached_photo_collection.last
        #     variant = att.variant(MauImage::Paperclip.variant_args(size)).processed if att
        #     Rails.application.routes.url_helpers.rails_representation_url(variant) if variant
        #   rescue Aws::S3::Errors::BadRequest => e
        #     Rails.logger.error(e.backtrace.join("\n"))
        #   end
        # end
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def attached_#{name}(size = :medium)
            begin
              # STI needs to query parent classes
              att = attached_#{name}_collection.last
              variant = att.variant(MauImage::Paperclip.variant_args(size)).processed if att
              Rails.application.routes.url_helpers.rails_representation_url(variant) if variant
            rescue Aws::S3::Errors::BadRequest => e
              Rails.logger.error(e.backtrace.join("\n"))
            end
          end
        RUBY
      end
    end
    # rubocop:enable Style/DocumentDynamicEvalDefinition
  end
end
