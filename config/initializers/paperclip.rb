# frozen_string_literal: true
if Rails.env != 'test'
  opts = {
    storage: :s3,
    s3_credentials: Rails.application.config.s3_info || {},
    url: ':s3_domain_url',
    path: '/:class/:attachment/:id_partition/:style/:filename',
    s3_region: Rails.application.config.s3_info[:s3_region] || 'us-west-1'
  }
  opts.each do |k, v|
    Paperclip::Attachment.default_options[k] = v
  end
else
  Paperclip::Attachment.default_options[:storage] = :filesystem
end
