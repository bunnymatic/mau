OLD_LARGE_VARIANT = { resize_to_fill: [800, 800, { crop: :centre }] }.freeze

namespace :paperclip do
  desc 'one off - remove old large variant blobs'
  task purge_old_large_variants: [:environment] do
    [Studio, Artist, ArtPiece].each do |clz|
      Rails.logger.warn("Purging old large variants from #{clz.name}")
      clz.find_in_batches(batch_size: 200).each do |batch|
        batch.each do |item|
          atts = item.send(:attachments_by_name, 'photo')
          atts.each do |att|
            variant = att.variant(OLD_LARGE_VARIANT)

            att.service.delete(variant.key)
          end
        end
      end
      Rails.logger.warn("Done purging old large variants from #{clz.name}")
    end
  end
end
