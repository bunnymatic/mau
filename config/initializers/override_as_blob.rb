Rails.application.config.to_prepare do
  ActiveStorage::Blob.class_eval do
    def analyzed?
      Rails.env.test? || super
    end
  end
end
