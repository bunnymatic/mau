class BlobObserver < ActiveRecord::Observer
  #  observe ActiveStorage::Blob

  # def after_save(blob)
  #   s3_url = CGI.escape("https://#{Rails.application.config.s3_info[:bucket]}.s3.amazonaws.com/#{blob.key}")

  #   blob.update_columns(storage_url: s3_url)
  # end
end
