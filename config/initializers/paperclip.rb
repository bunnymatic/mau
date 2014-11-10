if Rails.env != 'test'
  opts = {
    storage: :s3,
    s3_credentials: Rails.application.config.s3_info || {},
    url: ':s3_domain_url',
    path: "/:class/:attachment/:id_partition/:style/:filename"
  }
  opts.each do |k,v|
    Paperclip::Attachment.default_options[k] = v
  end
else
  Paperclip::Attachment.default_options[:storage] = :filesystem
end
