if Rails.env != 'test'

  s3_region = case Rails.env
              when "production"
                'us-east-1'
              else
                'us-west-1'
              end
  opts = {
    storage: :s3,
    s3_credentials: Rails.application.config.s3_info || {},
    url: ':s3_domain_url',
    path: "/:class/:attachment/:id_partition/:style/:filename",
    s3_region: s3_region
  }
  opts.each do |k,v|
    Paperclip::Attachment.default_options[k] = v
  end
else
  Paperclip::Attachment.default_options[:storage] = :filesystem
end
