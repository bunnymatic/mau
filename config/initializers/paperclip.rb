if Rails.env.test?
  Paperclip::Attachment.default_options[:storage] = :filesystem
else
  opts = {
    storage: :s3,
    url: ':s3_domain_url',
    path: '/:class/:attachment/:id_partition/:style/:filename',
    s3_credentials: Rails.application.config.s3_info || {},
    s3_protocol: :https,
    s3_region: Rails.application.config.s3_info[:s3_region] || 'us-west-1',
  }
  opts.each do |k, v|
    Paperclip::Attachment.default_options[k] = v
  end
end
